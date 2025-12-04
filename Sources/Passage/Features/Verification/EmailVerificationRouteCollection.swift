import Vapor

struct EmailVerificationRouteCollection: RouteCollection {

    let config: Passage.Configuration.Verification.Email
    let group: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = group.isEmpty ? builder : builder.grouped(group)

        grouped.post(config.routes.verify.path, use: send)
        grouped.get(config.routes.verify.path, use: verify)
        grouped.post(config.routes.resend.path, use: resend)
    }

}

// MARK: - Send Code

extension EmailVerificationRouteCollection {

    func send(_ req: Request) async throws -> HTTPStatus {
        let accessToken = try await req.jwt.verify(as: AccessToken.self)

        guard let user = try await req.store.users.find(byId: accessToken.subject.value) else {
            throw AuthenticationError.userNotFound
        }

        guard !user.isEmailVerified else {
            throw AuthenticationError.emailAlreadyVerified
        }

        // Use the verification service (handles queue dispatch or sync)
        try await req.verification.sendEmailCode(to: user)

        return .ok
    }

}

// MARK: - Verify

extension EmailVerificationRouteCollection {

    func verify(_ req: Request) async throws -> HTTPStatus {
        let accessToken = try await req.jwt.verify(as: AccessToken.self)
        let formType = req.contracts.emailVerificationForm
        try formType.validate(content: req)
        let form = try req.query.decode(formType.self)
        try form.validate()

        guard let user = try await req.store.users.find(byId: accessToken.subject.value) else {
            throw AuthenticationError.userNotFound
        }

        guard let email = user.email else {
            throw AuthenticationError.emailNotSet
        }

        let hash = req.random.hashOpaqueToken(token: form.code)

        guard let storedCode = try await req.store.verificationCodes.findEmailCode(
            forEmail: email,
            codeHash: hash
        ) else {
            throw AuthenticationError.invalidVerificationCode
        }

        guard storedCode.isValid(maxAttempts: config.maxAttempts) else {
            throw AuthenticationError.verificationCodeExpiredOrMaxAttempts
        }

        // Mark as verified
        try await req.store.users.markEmailVerified(for: user)

        // Invalidate used code
        try await req.store.verificationCodes.invalidateEmailCodes(forEmail: email)

        // Optionally send confirmation
        if let delivery = req.emailDelivery {
            try? await delivery.sendEmailVerificationConfirmation(to: email, user: user)
        }

        return .ok
    }

}

// MARK: - Resend

extension EmailVerificationRouteCollection {

    func resend(_ req: Request) async throws -> HTTPStatus {
        try await send(req)
    }

}
