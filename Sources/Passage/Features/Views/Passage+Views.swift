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
        let sources = try app.leaf.sources
        try sources.register(
            source: "passage",
            using: NIOLeafFiles(
                fileio: app.fileio,
                limits: .default,
                sandboxDirectory: "\(resourcePath)/Views",
                viewDirectory: "\(resourcePath)/Views"
            )
        )
        try app.leaf.sources = sources
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
                    byUsername: view.identifier == .username
                ),
            ),
        )
    }

    func handleLoginForm() async throws {
        let form = try request.decodeContentAsFormOfType(request.contracts.loginForm)

        print("Login form received: \(form)")
//        let identifier = try form.asIdentifier()
//
//        let user = try await request.authentication.authenticate(
//            identifier: identifier,
//            password: form.password
//        )
//
//        try await request.authentication.login(user: user)
    }

}

// MARK: - Password Reset Request View Implementation

extension Passage.Views {

    func renderResetPasswordRequestView() async throws -> View {
        guard let view = config.passwordResetRequest else {
            throw Abort(.notFound)
        }
        let params = try request.query.decode(ResetPasswordRequestViewContext.self)
        return try await request.view.render(
            view.template,
            Context(
                theme: view.theme.resolve(for: .light),
                params: params,
            ),
        )
    }

    func handleResetPasswordRequestForm() async throws {
        try PasswordResetRequestForm.validate(request)
        let form = try request.content.decode(PasswordResetRequestForm.self)
        try form.validate()

        let identifier = try form.asIdentifier()

        try await request.restoration.requestReset(for: identifier)
    }

}

// MARK: - Password Reset Confirm View Implementation

extension Passage.Views {

    func renderResetPasswordConfirmView() async throws -> View {
        guard let view = config.passwordResetRequest else {
            throw Abort(.notFound)
        }
        let params = try request.query.decode(ResetPasswordConfirmViewContext.self)
        return try await request.view.render(
            view.template,
            Context(
                theme: view.theme.resolve(for: .light),
                params: params,
            ),
        )
    }

    func handleResetPasswordConfirmForm() async throws {
        try PasswordResetConfirmForm.validate(request)
        let form = try request.content.decode(PasswordResetConfirmForm.self)
        try form.validate()

        let identifier = try form.asIdentifier()

        let passwordHash = try Bcrypt.hash(form.newPassword)

        try await request.restoration.verifyAndResetPassword(
            identifier: identifier,
            code: form.code,
            newPasswordHash: passwordHash
        )
    }

}
