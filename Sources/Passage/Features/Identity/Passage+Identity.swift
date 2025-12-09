import Vapor

extension Passage {

    struct Identity: Sendable {
        let request: Request
    }
}

// MARK: - Service Accessors

extension Passage.Identity {
    
    var store: Passage.Store {
        request.store
    }

    var random: Passage.RandomGenerator {
        request.random
    }

    var configuration: Passage.Configuration {
        request.configuration
    }

    var verification: Passage.Verification {
        request.verification
    }

    var contracts: Passage.Contracts {
        request.contracts
    }
}

// MARK: - Request Extension

extension Request {
    var identity: Passage.Identity {
        Passage.Identity(request: self)
    }
}

// MARK: - Registration

extension Passage.Identity {

    func register(form: any RegisterForm) async throws {
        let hash = try await request.password.async.hash(form.password)

        let credential = try form.asCredential(hash: hash)

        try await store.users.create(with: credential)

        // Send verification code after registration
        // Find the newly created user and send verification based on identifier type
        if let user = try await store.users.find(byIdentifier: credential.identifier) {
            // Fire-and-forget: don't fail registration if verification send fails
            try? await verification.sendVerificationCode(
                for: user,
                identifierKind: credential.identifier.kind
            )
        }
    }

}

// MARK: - Login

extension Passage.Identity {

    func login(form: any LoginForm) async throws -> AuthUser {
        let identifier = try form.asIdentifier()

        guard let user = try await store.users.find(byIdentifier: identifier) else {
            throw identifier.errorWhenIdentifierIsInvalid
        }

        guard let userPasswordHash = user.passwordHash else {
            throw AuthenticationError.passwordIsNotSet
        }

        try user.check(identifier: identifier)

        guard try await request.password.async.verify(form.password, created: userPasswordHash) else {
            throw identifier.errorWhenIdentifierIsInvalid
        }

        request.passage.login(user)

        try await store.tokens.revokeRefreshToken(for: user)

        let accessToken = AccessToken(
            userId: try user.requiredIdAsString,
            expiresAt: .now.addingTimeInterval(configuration.tokens.accessToken.timeToLive),
            issuer: configuration.tokens.issuer,
            audience: nil,
            scope: nil
        )

        let opaqueToken = random.generateOpaqueToken()
        try await store.tokens.createRefreshToken(
            for: user,
            tokenHash: random.hashOpaqueToken(token: opaqueToken),
            expiresAt: .now.addingTimeInterval(configuration.tokens.refreshToken.timeToLive)
        )

        return AuthUser(
            accessToken: try await request.jwt.sign(accessToken),
            refreshToken: opaqueToken,
            tokenType: "Bearer",
            expiresIn: configuration.tokens.accessToken.timeToLive,
            user: .init(
                id: try user.requiredIdAsString,
                email: user.email,
                phone: user.phone
            )
        )
    }

}

// MARK: - Token Refresh

extension Passage.Identity {

    func refreshToken(form: any RefreshTokenForm) async throws -> AuthUser {
        let hash = random.hashOpaqueToken(token: form.refreshToken)

        guard let refreshToken = try await store.tokens.find(refreshTokenHash: hash) else {
            throw AuthenticationError.refreshTokenNotFound
        }

        guard refreshToken.isValid else {
            try await store.tokens.revoke(refreshTokenFamilyStartingFrom: refreshToken)
            throw AuthenticationError.invalidRefreshToken
        }

        let user = refreshToken.user

        let opaqueToken = random.generateOpaqueToken()
        try await store.tokens.createRefreshToken(
            for: user,
            tokenHash: random.hashOpaqueToken(token: opaqueToken),
            expiresAt: .now.addingTimeInterval(configuration.tokens.refreshToken.timeToLive),
            replacing: refreshToken
        )

        let accessToken = AccessToken(
            userId: try user.requiredIdAsString,
            expiresAt: .now.addingTimeInterval(configuration.tokens.accessToken.timeToLive),
            issuer: configuration.tokens.issuer,
            audience: nil,
            scope: nil
        )

        return AuthUser(
            accessToken: try await request.jwt.sign(accessToken),
            refreshToken: opaqueToken,
            tokenType: "Bearer",
            expiresIn: configuration.tokens.accessToken.timeToLive,
            user: .init(
                id: try user.requiredIdAsString,
                email: user.email,
                phone: user.phone
            )
        )
    }

}

// MARK: - Logout

extension Passage.Identity {

    func logout() async throws {
        guard let user = try? request.passage.user else {
            return
        }
        request.passage.logout()
        try await store.tokens.revokeRefreshToken(for: user)
    }

}

// MARK: - Current User

extension Passage.Identity {

    func user(for accessToken: AccessToken) async throws -> any User {
        let userId = accessToken.subject.value

        guard let user = try await store.users.find(byId: userId) else {
            throw AuthenticationError.userNotFound
        }

        return user
    }

    func user(withId userId: String) async throws -> any User {
        guard let user = try await store.users.find(byId: userId) else {
            throw AuthenticationError.userNotFound
        }

        return user
    }

    func currentUser() throws -> AuthUser.User {

        let user = try request.passage.user

        return .init(
            id: try user.requiredIdAsString,
            email: user.email,
            phone: user.phone
        )
    }

}
