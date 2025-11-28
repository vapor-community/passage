//
//  PhoneVerificationRouteCollection.swift
//  passten
//
//  Created by Max Rozdobudko on 11/28/25.
//

import Vapor

struct PhoneVerificationRouteCollection: RouteCollection {

    let config: Identity.Configuration.Verification.Phone
    let groupPath: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = groupPath.isEmpty ? builder : builder.grouped(groupPath)

        grouped.post(config.routes.sendCode.path, use: sendCode)
        grouped.post(config.routes.verify.path, use: verify)
        grouped.post(config.routes.resend.path, use: resend)
    }

}

// MARK: - Send Code

extension PhoneVerificationRouteCollection {

    func sendCode(_ req: Request) async throws -> HTTPStatus {
        let accessToken = try await req.jwt.verify(as: AccessToken.self)

        guard let user = try await req.store.users.find(byId: accessToken.subject.value) else {
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

extension PhoneVerificationRouteCollection {

    struct VerifyForm: Content {
        let code: String
    }

    func verify(_ req: Request) async throws -> HTTPStatus {
        let accessToken = try await req.jwt.verify(as: AccessToken.self)
        let form = try req.content.decode(VerifyForm.self)

        guard let user = try await req.store.users.find(byId: accessToken.subject.value) else {
            throw AuthenticationError.userNotFound
        }

        guard let phone = user.phone else {
            throw AuthenticationError.phoneNotSet
        }

        let hash = req.random.hashOpaqueToken(token: form.code)

        guard let storedCode = try await req.store.codes.findPhoneCode(
            forPhone: phone,
            codeHash: hash
        ) else {
            throw AuthenticationError.invalidVerificationCode
        }

        guard storedCode.isValid(maxAttempts: config.maxAttempts) else {
            throw AuthenticationError.verificationCodeExpiredOrMaxAttempts
        }

        // Mark as verified
        try await req.store.users.markPhoneVerified(for: user)

        // Invalidate used code
        try await req.store.codes.invalidatePhoneCodes(forPhone: phone)

        // Optionally send confirmation
        if let delivery = req.phoneDelivery {
            try? await delivery.sendVerificationConfirmation(to: phone, user: user)
        }

        return .ok
    }

}

// MARK: - Resend

extension PhoneVerificationRouteCollection {

    func resend(_ req: Request) async throws -> HTTPStatus {
        try await sendCode(req)
    }

}
