import Vapor

extension Passage.Passwordless {

    struct MagicLinkEmailRouteCollection: Vapor.RouteCollection {

        let routes: Passage.Configuration.Passwordless.MagicLink.Routes
        let group: [PathComponent]

        func boot(routes builder: any RoutesBuilder) throws {
            let grouped = group.isEmpty ? builder : builder.grouped(group)

            grouped.post(routes.request.path, use: request)
            grouped.get(routes.verify.path, use: verify)
            grouped.post(routes.resend.path, use: resend)
        }

    }

}

// MARK: - Request Magic Link

extension Passage.Passwordless.MagicLinkEmailRouteCollection {

    func request(_ req: Request) async throws -> Response {
        do {
            let form = try req.decodeContentAsFormOfType(req.contracts.emailMagicLinkRequestForm)
            try await req.passwordless.requestEmailMagicLink(email: form.email)

            // Check if this is form submission (HTML)
            guard req.isFormSubmission,
                  req.isWaitingForHTML,
                  let view = req.configuration.views.magicLinkRequest else {
                return try await HTTPStatus.ok.encodeResponse(for: req)
            }

            // Redirect to success view with email
            return req.views.handleMagicLinkRequestSuccess(
                of: view,
                at: group + routes.request.path,
                email: form.email
            )

        } catch {
            guard req.isFormSubmission,
                  req.isWaitingForHTML,
                  let view = req.configuration.views.magicLinkRequest else {
                throw error
            }

            return req.views.handleMagicLinkRequestFailure(
                of: view,
                at: group + routes.request.path,
                with: error
            )
        }
    }

}

// MARK: - Verify Magic Link

extension Passage.Passwordless.MagicLinkEmailRouteCollection {

    func verify(_ req: Request) async throws -> Response {
        do {
            let form = try req.query.decode(Passage.DefaultEmailMagicLinkVerifyForm.self)
            let authUser = try await req.passwordless.verifyEmailMagicLink(token: form.token)

            guard let view = req.configuration.views.magicLinkVerify else {
                return try await authUser.encodeResponse(for: req)
            }

            let html = try await req.views.renderMagicLinkVerifySuccess(
                of: view,
                at: group + routes.verify.path
            )

            return try await html.encodeResponse(for: req)

        } catch {
            guard let view = req.configuration.views.magicLinkVerify else {
                throw error
            }

            let html = try await req.views.renderMagicLinkVerifyFailure(
                of: view,
                at: group + routes.verify.path,
                with: error,
                loginPath: req.configuration.routes.login.path
            )

            return try await html.encodeResponse(for: req)
        }
    }

}

// MARK: - Resend Magic Link

extension Passage.Passwordless.MagicLinkEmailRouteCollection {

    func resend(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.emailMagicLinkResendForm)
        try await req.passwordless.resendEmailMagicLink(email: form.email)
        return .ok
    }

}
