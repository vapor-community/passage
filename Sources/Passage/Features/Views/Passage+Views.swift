import Vapor
import Leaf
import LeafKit

// MARK: - Views Namespace

public extension Passage {

    struct Views {
        let request: Request
        let config: Configuration.Views
    }

}

extension Passage.Views {

    static func registerLeafTempleates(
        on app: Application
    ) throws {
        guard let resourcePath = Bundle.module.resourcePath else {
            throw PassageError.unexpected(message: "Could not locate resource path for Passage module.")
        }
        let sources = app.leaf.sources
        try sources.register(
            source: "passage",
            using: NIOLeafFiles(
                fileio: app.fileio,
                limits: .default,
                sandboxDirectory: "\(resourcePath)/Views",
                viewDirectory: "\(resourcePath)/Views"
            )
        )
        app.leaf.sources = sources
    }

}

extension Request {

    var views: Passage.Views {
        .init(request: self, config: configuration.views)
    }

}

// MARK: - Login View Implementation

extension Passage.Views {

    func renderLoginView() async throws -> View {
        guard let view = config.login else {
            throw Abort(.notFound)
        }
        let params = try request.query.decode(LoginViewContext.self)
        return try await request.view.render(
            view.template,
            Context(
                theme: view.theme.resolve(for: .light),
                params: params.copyWith(
                    byEmail: view.identifier == .email,
                    byPhone: view.identifier == .phone,
                    byUsername: view.identifier == .username,
                    withGoogle: true,
                    registerLink: "/test",
                    resetPasswordLink: "/test",
                ),
            ),
        )
    }

    func handleLoginFormSuccess(
        of view: Passage.Configuration.Views.LoginView,
        at path: [PathComponent],
    ) -> Response {
        return redirect(
            view: view,
            at: path,
            withSuccessMessage: "You have successfully logged in.",
        )
    }

    func handleLoginFormFailure(
        of view: Passage.Configuration.Views.LoginView,
        at path: [PathComponent],
        with error: any Error,
    ) -> Response {
        return redirect(
            view: view,
            at: path,
            withError: error,
            withDefaultMessage: "An unknown error occurred during login.",
        )
    }
}

// MARK: - Register View Implementation

extension Passage.Views {

    func renderRegisterView() async throws -> View {
        guard let view = config.register else {
            throw Abort(.notFound)
        }
        let params = try request.query.decode(RegisterViewContext.self)
        return try await request.view.render(
            view.template,
            Context(
                theme: view.theme.resolve(for: .light),
                params: params.copyWith(
                    byEmail: view.identifier == .email,
                    byPhone: view.identifier == .phone,
                    byUsername: view.identifier == .username,
                    withApple: true,
                    withGoogle: true,
                    loginLink: "/test"
                ),
            ),
        )
    }

    func handleRegisterFormSuccess(
        of view: Passage.Configuration.Views.RegisterView,
        at path: [PathComponent],
    ) -> Response {
        return redirect(
            view: view,
            at: path,
            withSuccessMessage: "You have successfully registered.",
        )
    }

    func handleRegisterFormFailure(
        of view: Passage.Configuration.Views.RegisterView,
        at path: [PathComponent],
        with error: any Error,
    ) -> Response {
        return redirect(
            view: view,
            at: path,
            withError: error,
            withDefaultMessage: "An unknown error occurred during registration.",
        )
    }

}

// MARK: - Password Reset Request View Implementation

extension Passage.Views {

    func renderResetPasswordRequestView(
        for identifier: Identifier.Kind
    ) async throws -> View {
        guard let view = config.passwordResetRequest else {
            throw Abort(.notFound)
        }
        let params = try request.query.decode(ResetPasswordRequestViewContext.self)
        return try await request.view.render(
            view.template,
            Context(
                theme: view.theme.resolve(for: .light),
                params: params.copyWith(
                    byEmail: identifier == .email,
                    byPhone: identifier == .phone,
                ),
            ),
        )
    }

    func handleResetPasswordRequestFormSuccess(
        of view: Passage.Configuration.Views.PasswordResetRequestView,
        at path: [PathComponent],
    ) -> Response {
        return request.redirect(
            to: buildRedirectLocation(
                for: path,
                success: "If an account with that identifier exists, a password reset link has been sent."
            )
        )
    }

    func handleResetPasswordRequestFormFailure(
        of view: Passage.Configuration.Views.PasswordResetRequestView,
        at path: [PathComponent],
        with error: any Error,
    ) -> Response {
        return redirect(
            view: view,
            at: path,
            withError: error,
            withDefaultMessage: "An unknown error occurred during password reset request.",
        )
    }

}

// MARK: - Password Reset Confirm View Implementation

extension Passage.Views {

    func renderResetPasswordConfirmView(
        for identifier: Identifier.Kind
    ) async throws -> View {
        guard let view = config.passwordResetConfirm else {
            throw Abort(.notFound)
        }
        let params = try request.query.decode(ResetPasswordConfirmViewContext.self)
        return try await request.view.render(
            view.template,
            Context(
                theme: view.theme.resolve(for: .light),
                params: params.copyWith(
                    byEmail: identifier == .email,
                    byPhone: identifier == .phone,
                ),
            ),
        )
    }

    func handleResetPasswordConfirmFormSuccess(
        of view: Passage.Configuration.Views.PasswordResetConfirmView,
        at path: [PathComponent],
    ) -> Response {
        return redirect(
            view: view,
            at: path,
            withSuccessMessage: "Your password has been successfully reset.",
        )
    }

    func handleResetPasswordConfirmFormFailure(
        of view: Passage.Configuration.Views.PasswordResetConfirmView,
        at path: [PathComponent],
        with error: any Error,
    ) -> Response {
        return redirect(
            view: view,
            at: path,
            withError: error,
            withDefaultMessage: "An unknown error occurred during password reset.",
        )
    }

}

// MARK: - Redirect Helpers

fileprivate extension Passage.Views {

    func redirect(
        view: Passage.Configuration.Views.View,
        at path: [PathComponent],
        withParams params: [String: String?] = [:],
        withSuccessMessage success: String,
    ) -> Response {
        guard let location = view.redirect.onSuccess else {
            return request.redirect(
                to: buildRedirectLocation(
                    for: path,
                    params: params,
                    success: success,
                )
            )
        }
        return request.redirect(to: location)
    }

    func redirect(
        view: Passage.Configuration.Views.View,
        at path: [PathComponent],
        withParams params: [String: String?] = [:],
        withError error: Error,
        withDefaultMessage message: String = "An unexpected error occurred. Please try again.",
    ) -> Response {
        guard let location = view.redirect.onFailure else {
            return request.redirect(
                to: buildRedirectLocation(
                    for: path,
                    params: params,
                    error: (error as? AuthenticationError)?.localizedDescription ?? message
                )
            )
        }
        return request.redirect(to: location)
    }

}

// MARK: - Redirect Location Builder

extension Passage.Views {

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
        return components.string ?? "/"
    }
}
