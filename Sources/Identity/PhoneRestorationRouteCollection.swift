//
//  PhoneRestorationRouteCollection.swift
//  passten
//
//  Created by Max Rozdobudko on 12/01/25.
//

import Vapor

struct PhoneRestorationRouteCollection: RouteCollection {

    let config: Identity.Configuration.Restoration.Phone
    let groupPath: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = groupPath.isEmpty ? builder : builder.grouped(groupPath)

        grouped.post(config.routes.request.path, use: request)
        grouped.post(config.routes.verify.path, use: verify)
        grouped.post(config.routes.resend.path, use: resend)
    }

}

// MARK: - Request Reset

extension PhoneRestorationRouteCollection {

    struct RequestForm: Content {
        let phone: String
    }

    func request(_ req: Request) async throws -> HTTPStatus {
        let form = try req.content.decode(RequestForm.self)
        let identifier = Identifier(kind: .phone, value: form.phone)
        try await req.restoration.requestReset(for: identifier)
        return .ok
    }

}

// MARK: - Verify and Reset Password

extension PhoneRestorationRouteCollection {

    struct VerifyForm: Content {
        let phone: String
        let code: String
        let newPassword: String
    }

    func verify(_ req: Request) async throws -> HTTPStatus {
        let form = try req.content.decode(VerifyForm.self)
        let identifier = Identifier(kind: .phone, value: form.phone)

        // Hash the new password
        let passwordHash = try Bcrypt.hash(form.newPassword)

        try await req.restoration.verifyAndResetPassword(
            identifier: identifier,
            code: form.code,
            newPasswordHash: passwordHash
        )

        return .ok
    }

}

// MARK: - Resend

extension PhoneRestorationRouteCollection {

    struct ResendForm: Content {
        let phone: String
    }

    func resend(_ req: Request) async throws -> HTTPStatus {
        let form = try req.content.decode(ResendForm.self)
        try await req.restoration.resendPhoneResetCode(phone: form.phone)
        return .ok
    }

}
