import Vapor

extension Passage.Verification {

    struct PhoneRouteCollection: Vapor.RouteCollection {

        let config: Passage.Configuration.Verification.Phone
        let groupPath: [PathComponent]

        func boot(routes builder: any RoutesBuilder) throws {
            let grouped = groupPath.isEmpty ? builder : builder.grouped(groupPath)

            grouped.post(config.routes.sendCode.path, use: sendCode)
            grouped.post(config.routes.verify.path, use: verify)
            grouped.post(config.routes.resend.path, use: resend)
        }

    }

}

// MARK: - Send Code

extension Passage.Verification.PhoneRouteCollection {

    func sendCode(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.phoneVerificationRequestForm)

        guard let user = try await req.store.users.find(
            byIdentifier: .phone(form.phone)
        ) else {
            throw AuthenticationError.userNotFound
        }

        guard !user.isPhoneVerified else {
            throw AuthenticationError.phoneAlreadyVerified
        }

        // Use the verification service (handles queue dispatch or sync)
        try await req.verification.sendPhoneCode(to: user)

        return .ok
    }

}

// MARK: - Verify

extension Passage.Verification.PhoneRouteCollection {

    func verify(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeQueryAsFormOfType(req.contracts.phoneVerificationConfirmForm)

        let hash = req.random.hashOpaqueToken(token: form.code)

        guard let code = try await req.store.verificationCodes.findPhoneCode(
            forPhone: form.phone,
            codeHash: hash
        ) else {
            throw AuthenticationError.invalidVerificationCode
        }
        
        guard code.isValid(maxAttempts: config.maxAttempts) else {
            throw AuthenticationError.verificationCodeExpiredOrMaxAttempts
        }
        
        // Mark as verified
        try await req.store.users.markPhoneVerified(for: code.user)
        
        // Invalidate used code
        try await req.store.verificationCodes.invalidatePhoneCodes(forPhone: code.phone)

        // Optionally send confirmation
        if let delivery = req.phoneDelivery {
            try? await delivery.sendVerificationConfirmation(to: code.phone, user: code.user)
        }

        return .ok
    }

}

// MARK: - Resend

extension Passage.Verification.PhoneRouteCollection {

    func resend(_ req: Request) async throws -> HTTPStatus {
        try await sendCode(req)
    }

}
