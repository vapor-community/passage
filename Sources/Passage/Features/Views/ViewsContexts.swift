import Vapor

// MARK: - View Context

extension Passage.Views {

    struct Context<Params>: Sendable, Encodable where Params: Sendable & Encodable {
        let theme: Theme.Resolved
        let params: Params
    }

}

// MARK: - Login View Context

extension Passage.Views {

    struct LoginViewContext: Content {
        let byEmail: Bool
        let byPhone: Bool
        let byUsername: Bool
        let withApple: Bool
        let withGoogle: Bool
        let withGitHub: Bool
        let error: String?
        let success: String?
        let registerLink: String?
        let resetPasswordLink: String?
        let byEmailMagicLink: Bool?
        let magicLinkRequestLink: String?

        func copyWith(
            byEmail: Bool? = nil,
            byPhone: Bool? = nil,
            byUsername: Bool? = nil,
            withApple: Bool? = nil,
            withGoogle: Bool? = nil,
            withGitHub: Bool? = nil,
            error: String? = nil,
            success: String? = nil,
            registerLink: String? = nil,
            resetPasswordLink: String? = nil,
            byEmailMagicLink: Bool? = nil,
            magicLinkRequestLink: String? = nil
        ) -> Self {
            .init(
                byEmail: byEmail ?? self.byEmail,
                byPhone: byPhone ?? self.byPhone,
                byUsername: byUsername ?? self.byUsername,
                withApple: withApple ?? self.withApple,
                withGoogle: withGoogle ?? self.withGoogle,
                withGitHub: withGitHub ?? self.withGitHub,
                error: error ?? self.error,
                success: success ?? self.success,
                registerLink: registerLink ?? self.registerLink,
                resetPasswordLink: resetPasswordLink ?? self.resetPasswordLink,
                byEmailMagicLink: byEmailMagicLink ?? self.byEmailMagicLink,
                magicLinkRequestLink: magicLinkRequestLink ?? self.magicLinkRequestLink
            )
        }
    }

}

// MARK: - Register View Context

extension Passage.Views {

    struct RegisterViewContext: Content {
        let byEmail: Bool
        let byPhone: Bool
        let byUsername: Bool
        let withApple: Bool
        let withGoogle: Bool
        let withGitHub: Bool
        let error: String?
        let success: String?
        let loginLink: String?

        func copyWith(
            byEmail: Bool? = nil,
            byPhone: Bool? = nil,
            byUsername: Bool? = nil,
            withApple: Bool? = nil,
            withGoogle: Bool? = nil,
            withGitHub: Bool? = nil,
            error: String? = nil,
            success: String? = nil,
            loginLink: String? = nil,
        ) -> Self {
            .init(
                byEmail: byEmail ?? self.byEmail,
                byPhone: byPhone ?? self.byPhone,
                byUsername: byUsername ?? self.byUsername,
                withApple: withApple ?? self.withApple,
                withGoogle: withGoogle ?? self.withGoogle,
                withGitHub: withGitHub ?? self.withGitHub,
                error: error ?? self.error,
                success: success ?? self.success,
                loginLink: loginLink ?? self.loginLink,
            )
        }
    }

}

// MARK: - Reset Password Request View Context

extension Passage.Views {

    struct ResetPasswordRequestViewContext: Content {
        let byEmail: Bool
        let byPhone: Bool
        let error: String?
        let success: String?

        func copyWith(
            byEmail: Bool? = nil,
            byPhone: Bool? = nil,
            error: String? = nil,
            success: String? = nil,
        ) -> Self {
            .init(
                byEmail: byEmail ?? self.byEmail,
                byPhone: byPhone ?? self.byPhone,
                error: error ?? self.error,
                success: success ?? self.success,
            )
        }
    }

}

// MARK: - Reset Password Confirmation View Context

extension Passage.Views {

    struct ResetPasswordConfirmViewContext: Content {
        let byEmail: Bool
        let byPhone: Bool
        let code: String
        let email: String?
        let error: String?
        let success: String?

        func copyWith(
            byEmail: Bool? = nil,
            byPhone: Bool? = nil,
            email: String? = nil,
            error: String? = nil,
            success: String? = nil,
        ) -> Self {
            .init(
                byEmail: byEmail ?? self.byEmail,
                byPhone: byPhone ?? self.byPhone,
                code: self.code,
                email: email ?? self.email,
                error: error ?? self.error,
                success: success ?? self.success,
            )
        }

    }

}

// MARK: - Magic Link Request View Context

extension Passage.Views {

    struct MagicLinkRequestViewContext: Content {
        let byEmail: Bool
        let error: String?
        let success: String?
        let identifier: String?

        func copyWith(
            byEmail: Bool? = nil,
            error: String? = nil,
            success: String? = nil,
            identifier: String? = nil
        ) -> Self {
            .init(
                byEmail: byEmail ?? self.byEmail,
                error: error ?? self.error,
                success: success ?? self.success,
                identifier: identifier ?? self.identifier
            )
        }
    }

}

// MARK: - Magic Link Verify View Context

extension Passage.Views {

    struct MagicLinkVerifyViewContext: Content {
        let error: String?
        let success: String?
        let redirectUrl: String?
        let loginLink: String?

        func copyWith(
            error: String? = nil,
            success: String? = nil,
            redirectUrl: String? = nil,
            loginLink: String? = nil
        ) -> Self {
            .init(
                error: error ?? self.error,
                success: success ?? self.success,
                redirectUrl: redirectUrl ?? self.redirectUrl,
                loginLink: loginLink ?? self.loginLink
            )
        }
    }

}

// MARK: - OAuth Link Select View Context

extension Passage.Views {

    struct LinkAccountSelectViewContext: Content {

        struct Candidate: Content {
            let userId: String
            let maskedEmail: String?
            let maskedPhone: String?
        }

        let provider: String
        let candidates: [Candidate]
        let error: String?
    }

}

// MARK: - OAuth Link Verify View Context

extension Passage.Views {

    struct LinkAccountVerifyViewContext: Content {
        let maskedEmail: String?
        let hasPassword: Bool
        let canUseEmailCode: Bool
        let error: String?
    }

}
