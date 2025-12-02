import Vapor

struct PassageRouteCollection: RouteCollection {

    init(routes: Passage.Configuration.Routes) {
        self.routes = routes
    }

    let routes: Passage.Configuration.Routes

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = routes.group.isEmpty ? builder : builder.grouped(routes.group)
        grouped.post(routes.register.path, use: self.register)
        grouped.post(routes.login.path, use: self.login)
        grouped.post(routes.refreshToken.path, use: self.refreshToken)
        grouped.post(routes.logout.path, use: self.logout)
        grouped.get(routes.currentUser.path, use: self.currentUser)
    }

}

extension PassageRouteCollection {

    fileprivate func register(_ req: Request) async throws -> HTTPStatus {
        try RegisterForm.validate(content: req)
        let register = try req.content.decode(RegisterForm.self)
        try register.validate()

        let hash = try await req.password.async.hash(register.password)

        let credential = try register.asCredential(hash: hash)

        try await req.store.users.create(with: credential)

        // Send verification code after registration
        // Find the newly created user and send verification based on identifier type
        if let user = try await req.store.users.find(byIdentifier: credential.identifier) {
            // Fire-and-forget: don't fail registration if verification send fails
            try? await req.verification.sendVerificationCode(
                for: user,
                identifierKind: credential.identifier.kind
            )
        }

        return .ok
    }

}

extension PassageRouteCollection {

    fileprivate func login(_ req: Request) async throws -> AuthUser {
        try LoginForm.validate(content: req)
        let login = try req.content.decode(LoginForm.self)

        let identifier = try login.asIdentifier()

        guard let user = try await req.store.users.find(byIdentifier: identifier) else {
            throw identifier.errorWhenIdentifierIsInvalid
        }

        guard let userPasswordHash = user.passwordHash else {
            throw AuthenticationError.passwordIsNotSet
        }

        try user.check(identifier: identifier)

        guard try await req.password.async.verify(login.password, created: userPasswordHash) else {
            throw identifier.errorWhenIdentifierIsInvalid
        }

        try await req.store.tokens.revokeRefreshToken(for: user)

        let accessToken = AccessToken(
            userId: try user.requiredIdAsString,
            expiresAt: .now.addingTimeInterval(req.tokens.accessToken.timeToLive),
            issuer: req.tokens.issuer,
            audience: nil,
            scope: nil
        )

        let opaqueToken = req.random.generateOpaqueToken()
        try await req.store.tokens.createRefreshToken(
            for: user,
            tokenHash: req.random.hashOpaqueToken(token: opaqueToken),
            expiresAt: .now.addingTimeInterval(req.tokens.refreshToken.timeToLive)
        )

        return AuthUser(
            accessToken: try await req.jwt.sign(accessToken),
            refreshToken: opaqueToken,
            tokenType: "Bearer",
            expiresIn: req.tokens.accessToken.timeToLive,
            user: .init(
                id: try user.requiredIdAsString,
                email: user.email,
                phone: user.phone
            )
        )
    }

}

// MARK: - Refresh Token

extension PassageRouteCollection {

    fileprivate func refreshToken(_ req: Request) async throws -> AuthUser {
        let form = try req.content.decode(RefreshTokenForm.self)

        let hash = req.random.hashOpaqueToken(token: form.refreshToken)

        guard let refreshToken = try await req.store.tokens.find(refreshTokenHash: hash) else {
            throw AuthenticationError.refreshTokenNotFound
        }

        guard refreshToken.isValid else {
            try await req.store.tokens.revoke(refreshTokenFamilyStartingFrom: refreshToken)
            throw AuthenticationError.invalidRefreshToken
        }

        let user = refreshToken.user

        let opaqueToken = req.random.generateOpaqueToken()
        try await req.store.tokens.createRefreshToken(
            for: user,
            tokenHash: req.random.hashOpaqueToken(token: opaqueToken),
            expiresAt: .now.addingTimeInterval(req.tokens.refreshToken.timeToLive),
            replacing: refreshToken
        )

        let accessToken = AccessToken(
            userId: try user.requiredIdAsString,
            expiresAt: .now.addingTimeInterval(req.tokens.accessToken.timeToLive),
            issuer: req.tokens.issuer,
            audience: nil,
            scope: nil
        )

        return AuthUser(
            accessToken: try await req.jwt.sign(accessToken),
            refreshToken: opaqueToken,
            tokenType: "Bearer",
            expiresIn: req.tokens.accessToken.timeToLive,
            user: .init(
                id: try user.requiredIdAsString,
                email: user.email,
                phone: user.phone
            )
        )
    }

}

// MARK: - Logout

extension PassageRouteCollection {

    fileprivate func logout(_ req: Request) async throws -> HTTPStatus {
        let form = try req.content.decode(RefreshTokenForm.self)

        let hash = req.random.hashOpaqueToken(token: form.refreshToken)
        try await req.store.tokens.revokeRefreshToken(withHash: hash)

        return .ok
    }

}

// MARK: - Current User

extension PassageRouteCollection {

    fileprivate func currentUser(_ req: Request) async throws -> AuthUser.User {
        let accessToken = try await req.jwt.verify(as: AccessToken.self)

        let userId = accessToken.subject.value

        guard let user = try await req.store.users.find(byId: userId) else {
            throw AuthenticationError.userNotFound
        }

        return .init(
            id: try user.requiredIdAsString,
            email: user.email,
            phone: user.phone,
        )
    }

}

// MARK: - IdTokenResponse

struct IdTokenResponse: Content {
    let idToken: String
}
