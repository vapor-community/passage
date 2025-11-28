//
//  EmailVerificationRouteCollection.swift
//  passten
//
//  Created by Max Rozdobudko on 11/28/25.
//

import Vapor

struct EmailVerificationRouteCollection: RouteCollection {

    let config: Identity.Configuration.Verification.Email
    let groupPath: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = groupPath.isEmpty ? builder : builder.grouped(groupPath)

        grouped.post(config.routes.sendCode.path, use: sendCode)
        grouped.post(config.routes.verify.path, use: verify)
        grouped.post(config.routes.resend.path, use: resend)
    }

}

// MARK: - Send Code

extension EmailVerificationRouteCollection {

    func sendCode(_ req: Request) async throws -> HTTPStatus {
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

    struct VerifyForm: Content {
        let code: String
    }

    func verify(_ req: Request) async throws -> HTTPStatus {
        let accessToken = try await req.jwt.verify(as: AccessToken.self)
        let form = try req.content.decode(VerifyForm.self)

        guard let user = try await req.store.users.find(byId: accessToken.subject.value) else {
            throw AuthenticationError.userNotFound
        }

        guard let email = user.email else {
            throw AuthenticationError.emailNotSet
        }

        let hash = req.random.hashOpaqueToken(token: form.code)

        guard let storedCode = try await req.store.codes.findEmailCode(
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
        try await req.store.codes.invalidateEmailCodes(forEmail: email)

        // Optionally send confirmation
        if let delivery = req.emailDelivery {
            try? await delivery.sendVerificationConfirmation(to: email, user: user)
        }

        return .ok
    }

}

// MARK: - Resend

extension EmailVerificationRouteCollection {

    func resend(_ req: Request) async throws -> HTTPStatus {
        try await sendCode(req)
    }

}
