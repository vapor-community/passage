//
//  EmailRestorationRouteCollection.swift
//  passten
//
//  Created by Max Rozdobudko on 12/01/25.
//

import Vapor

struct EmailRestorationRouteCollection: RouteCollection {

    let config: Identity.Configuration.Restoration.Email
    let groupPath: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = groupPath.isEmpty ? builder : builder.grouped(groupPath)

        grouped.post(config.routes.request.path, use: request)
        grouped.post(config.routes.verify.path, use: verify)
        grouped.post(config.routes.resend.path, use: resend)
    }

}

// MARK: - Request Reset

extension EmailRestorationRouteCollection {

    struct RequestForm: Content {
        let email: String
    }

    func request(_ req: Request) async throws -> HTTPStatus {
        let form = try req.content.decode(RequestForm.self)
        let identifier = Identifier(kind: .email, value: form.email)
        try await req.restoration.requestReset(for: identifier)
        return .ok
    }

}

// MARK: - Verify and Reset Password

extension EmailRestorationRouteCollection {

    struct VerifyForm: Content {
        let email: String
        let code: String
        let newPassword: String
    }

    func verify(_ req: Request) async throws -> HTTPStatus {
        let form = try req.content.decode(VerifyForm.self)
        let identifier = Identifier(kind: .email, value: form.email)

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

extension EmailRestorationRouteCollection {

    struct ResendForm: Content {
        let email: String
    }

    func resend(_ req: Request) async throws -> HTTPStatus {
        let form = try req.content.decode(ResendForm.self)
        try await req.restoration.resendEmailResetCode(email: form.email)
        return .ok
    }

}
