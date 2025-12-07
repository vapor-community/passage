import Vapor

// MARK: - Views Configuration

public extension Passage.Configuration {

    struct Views: Sendable {

        protocol View: Sendable {
            var name: String { get }
            var style: Passage.Views.Style { get }
            var theme: Passage.Views.Theme { get }
            var redirect: Redirect { get }
        }

        public struct Redirect: Sendable {
            let onSuccess: String?
            let onFailure: String?

            public init(
                onSuccess: String? = nil,
                onFailure: String? = nil,
            ) {
                self.onSuccess = onSuccess
                self.onFailure = onFailure
            }
        }

        let register: RegisterView?
        let login: LoginView?
        let passwordResetRequest: PasswordResetRequestView?
        let passwordResetConfirm: PasswordResetConfirmView?
        let magicLinkRequest: MagicLinkRequestView?
        let magicLinkVerify: MagicLinkVerifyView?

        public init(
            register: RegisterView? = nil,
            login: LoginView? = nil,
            passwordResetRequest: PasswordResetRequestView? = nil,
            passwordResetConfirm: PasswordResetConfirmView? = nil,
            magicLinkRequest: MagicLinkRequestView? = nil,
            magicLinkVerify: MagicLinkVerifyView? = nil
        ) {
            self.register = register
            self.login = login
            self.passwordResetRequest = passwordResetRequest
            self.passwordResetConfirm = passwordResetConfirm
            self.magicLinkRequest = magicLinkRequest
            self.magicLinkVerify = magicLinkVerify
        }
    }

}

// MARK: Views Extension

extension Passage.Configuration.Views {

    var enabled: Bool {
        return login != nil ||
        register != nil ||
        passwordResetRequest != nil ||
        passwordResetConfirm != nil ||
        magicLinkRequest != nil ||
        magicLinkVerify != nil
    }
}

// MARK: View Template Extension

extension Passage.Configuration.Views.View {

    var template: String {
        return "\(name)-\(style.templateSuffix)"
    }
}

// MARK: - Login View

public extension Passage.Configuration.Views {

    struct LoginView: Sendable, View {
        let name: String = "login"
        let style: Passage.Views.Style
        let theme: Passage.Views.Theme
        let redirect: Redirect
        let identifier: Identifier.Kind

        public init(
            style: Passage.Views.Style,
            theme: Passage.Views.Theme,
            redirect: Redirect = .init(),
            identifier: Identifier.Kind,
        ) {
            self.style = style
            self.theme = theme
            self.redirect = redirect
            self.identifier = identifier
        }
    }

}

// MARK: - Register View

public extension Passage.Configuration.Views {

    struct RegisterView: Sendable, View {
        let name: String = "register"
        let style: Passage.Views.Style
        let theme: Passage.Views.Theme
        let redirect: Redirect
        let identifier: Identifier.Kind

        public init(
            style: Passage.Views.Style,
            theme: Passage.Views.Theme,
            redirect: Redirect = .init(),
            identifier: Identifier.Kind,
        ) {
            self.style = style
            self.theme = theme
            self.redirect = redirect
            self.identifier = identifier
        }
    }

}

// MARK: - Password Reset View

public extension Passage.Configuration.Views {

    struct PasswordResetRequestView: Sendable, View {
        let name: String = "password-reset-request"
        let style: Passage.Views.Style
        let theme: Passage.Views.Theme
        let redirect: Redirect

        public init(
            style: Passage.Views.Style,
            theme: Passage.Views.Theme,
            redirect: Redirect = .init(),
        ) {
            self.style = style
            self.theme = theme
            self.redirect = redirect
        }
    }

    struct PasswordResetConfirmView: Sendable, View {
        let name: String = "password-reset-confirm"
        let style: Passage.Views.Style
        let theme: Passage.Views.Theme
        let redirect: Redirect

        public init(
            style: Passage.Views.Style,
            theme: Passage.Views.Theme,
            redirect: Redirect = .init(),
        ) {
            self.style = style
            self.theme = theme
            self.redirect = redirect
        }
    }

}

// MARK: - Magic Link Views

public extension Passage.Configuration.Views {

    struct MagicLinkRequestView: Sendable, View {
        let name: String = "magic-link-request"
        let style: Passage.Views.Style
        let theme: Passage.Views.Theme
        let redirect: Redirect

        public init(
            style: Passage.Views.Style,
            theme: Passage.Views.Theme,
            redirect: Redirect = .init()
        ) {
            self.style = style
            self.theme = theme
            self.redirect = redirect
        }
    }

    struct MagicLinkVerifyView: Sendable, View {
        let name: String = "magic-link-verify"
        let style: Passage.Views.Style
        let theme: Passage.Views.Theme
        let redirect: Redirect

        public init(
            style: Passage.Views.Style,
            theme: Passage.Views.Theme,
            redirect: Redirect
        ) {
            self.style = style
            self.theme = theme
            self.redirect = redirect
        }
    }

}
