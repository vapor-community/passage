import Vapor

struct ViewsRouteCollection: RouteCollection {

    let config: Passage.Configuration.Views
    let group: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = group.isEmpty ? builder : builder.grouped(group)

        addLoginViewRoutesIfNeeded(to: grouped)
        addPasswordResetRequestViewRoutesIfNeeded(to: grouped)
    }

}

// MARK: - Login View Handling

extension ViewsRouteCollection {

    func addLoginViewRoutesIfNeeded(
        to builder: some RoutesBuilder,
    ) {
        guard let view = config.login else {
            return
        }
        let path = view.route.path
        builder.get(path) { req in
            try await req.views.renderLoginView()
        }
        builder.post(path) { req in
            do {
                try await req.views.handleLoginForm()
                return req.redirect(
                    to: buildRedirectLocation(
                        for: group + path,
                        success: "You have successfully logged in."
                    )
                )
            } catch let error as AuthenticationError {
                return req.redirect(
                    to: buildRedirectLocation(
                        for: group + path,
                        error: error.reason
                    )
                )
            } catch {
                return req.redirect(
                    to: buildRedirectLocation(
                        for: group + path,
                        error: "An unexpected error occurred. Please try again."
                    )
                )
            }
        }
    }

}

// MARK: - Pasword Reset Request View Handling

extension ViewsRouteCollection {

    func addPasswordResetRequestViewRoutesIfNeeded(
        to builder: some RoutesBuilder,
    ) {
        guard let view = config.passwordResetRequest else {
            return
        }
        let path = view.route.path
        builder.get(path) { req in
            try await req.views.renderResetPasswordRequestView()
        }
        builder.post(path) { req in
            do {
                try await req.views.handleResetPasswordRequestForm()
                return req.redirect(
                    to: buildRedirectLocation(
                        for: group + path,
                        success: "If an account with that identifier exists, a password reset link has been sent."
                    )
                )
            } catch let error as AuthenticationError {
                return req.redirect(
                    to: buildRedirectLocation(
                        for: group + path,
                        error: error.reason
                    )
                )
            } catch {
                return req.redirect(
                    to: buildRedirectLocation(
                        for: group + path,
                        error: "An unexpected error occurred. Please try again."
                    )
                )
            }
        }
    }

}

// MARK: - Pasword Reset Confirm View Handling

extension ViewsRouteCollection {

    func addPasswordResetConfirmViewRoutesIfNeeded(
        to builder: some RoutesBuilder,
    ) {
        guard let view = config.passwordResetConfirm else {
            return
        }
        let path = view.route.path
        builder.get(path) { req in
            try await req.views.renderResetPasswordConfirmView()
        }
        builder.post(path) { req in
            do {
                try await req.views.handleResetPasswordConfirmForm()
                return req.redirect(
                    to: buildRedirectLocation(
                        for: group + path,
                        success: "Your password has been successfully reset. You may now log in with your new password."
                    )
                )
            } catch let error as AuthenticationError {
                return req.redirect(
                    to: buildRedirectLocation(
                        for: group + path,
                        error: error.reason
                    )
                )
            } catch {
                return req.redirect(
                    to: buildRedirectLocation(
                        for: group + path,
                        error: "An unexpected error occurred. Please try again."
                    )
                )
            }
        }
    }

}

// MARK: - Helpers

extension ViewsRouteCollection {

    func buildRedirectLocation(
        for path: [PathComponent],
        params: [String: String?] = [:],
        success: String? = nil,
        error: String? = nil,
    ) -> String {
        var components = URLComponents()
        components.path = "/\(path.string)"
        components.queryItems = params.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        if let success {
            components.queryItems?.append(URLQueryItem(name: "success", value: success))
        }
        if let error {
            components.queryItems?.append(URLQueryItem(name: "error", value: error))
        }
        return components.string ?? "/\(path.string)"
    }

}
