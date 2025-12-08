import Vapor

extension Passage.Verification {

    struct EmailRouteCollection: Vapor.RouteCollection {

        let config: Passage.Configuration.Verification.Email
        let group: [PathComponent]

        func boot(routes builder: any RoutesBuilder) throws {
            let grouped = group.isEmpty ? builder : builder.grouped(group)

            grouped.post(config.routes.verify.path, use: send)
            grouped.get(config.routes.verify.path, use: verify)
            grouped.post(config.routes.resend.path, use: resend)
        }

    }

}

// MARK: - Send Code

extension Passage.Verification.EmailRouteCollection {

    func send(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.emailVerificationRequestForm)

        guard let user = try await req.store.users.find(
            byIdentifier: .email(form.email)
        ) else {
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

extension Passage.Verification.EmailRouteCollection {

    func verify(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeQueryAsFormOfType(req.contracts.emailVerificationConfirmForm)

        let hash = req.random.hashOpaqueToken(token: form.code)

        guard let code = try await req.store.verificationCodes.findEmailCode(
            forEmail: form.email,
            codeHash: hash
        ) else {
            throw AuthenticationError.invalidVerificationCode
        }

        guard code.isValid(maxAttempts: config.maxAttempts) else {
            throw AuthenticationError.verificationCodeExpiredOrMaxAttempts
        }

        // Mark as verified
        try await req.store.users.markEmailVerified(for: code.user)

        // Invalidate used code
        try await req.store.verificationCodes.invalidateEmailCodes(forEmail: code.email)

        // Optionally send confirmation
        if let delivery = req.emailDelivery {
            try? await delivery.sendEmailVerificationConfirmation(to: code.email, user: code.user)
        }

        return .ok
    }

}

// MARK: - Resend

extension Passage.Verification.EmailRouteCollection {

    func resend(_ req: Request) async throws -> HTTPStatus {
        try await send(req)
    }

}
