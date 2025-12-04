import Vapor

struct EmailRestorationRouteCollection: RouteCollection {

    let routes: Passage.Configuration.Restoration.Email.Routes
    let group: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = group.isEmpty ? builder : builder.grouped(group)

        grouped.post(routes.request.path, use: request)
        grouped.post(routes.verify.path, use: verify)
        grouped.post(routes.resend.path, use: resend)
    }

}

// MARK: - Request Reset

extension EmailRestorationRouteCollection {

    func request(_ req: Request) async throws -> Response {
        do {
            let form = try req.decodeContentAsFormOfType(req.contracts.emailPasswordResetRequestForm)
            let identifier = Identifier(kind: .email, value: form.email)
            try await req.restoration.requestReset(for: identifier)

            guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.passwordResetRequest else {
                return try await HTTPStatus.ok.encodeResponse(for: req)
            }

            return req.views.handleResetPasswordRequestFormSuccess(
                of: view,
                at: group + routes.request.path,
            )
        } catch {
            guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.passwordResetRequest else {
                throw error
            }

            return req.views.handleResetPasswordRequestFormFailure(
                of: view,
                at: group + routes.request.path,
                with: error
            )
        }
    }

}

// MARK: - Verify and Reset Password

extension EmailRestorationRouteCollection {

    func verify(_ req: Request) async throws -> Response {
        do {
            let form = try req.decodeContentAsFormOfType(req.contracts.emailPasswordResetVerifyForm)
            let identifier = Identifier(kind: .email, value: form.email)

            // Hash the new password
            let passwordHash = try Bcrypt.hash(form.newPassword)

            try await req.restoration.verifyAndResetPassword(
                identifier: identifier,
                code: form.code,
                newPasswordHash: passwordHash
            )

            guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.passwordResetConfirm else {
                return try await HTTPStatus.ok.encodeResponse(for: req)
            }

            return req.views.handleResetPasswordConfirmFormSuccess(
                of: view,
                at: group + routes.verify.path,
            )
        } catch {
            guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.passwordResetConfirm else {
                throw error
            }

            return req.views.handleResetPasswordConfirmFormFailure(
                of: view,
                at: group + routes.verify.path,
                with: error
            )
        }
    }

}

// MARK: - Resend

extension EmailRestorationRouteCollection {

    func resend(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.emailPasswordResetResendForm)
        try await req.restoration.resendPasswordResetCode(toEmail: form.email)
        return .ok
    }

}
