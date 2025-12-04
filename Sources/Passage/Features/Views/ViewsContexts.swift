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
        let withGoogle: Bool
        let error: String?
        let success: String?

        func copyWith(
            byEmail: Bool? = nil,
            byPhone: Bool? = nil,
            byUsername: Bool? = nil,
            withGoogle: Bool? = nil,
            error: String? = nil,
            success: String? = nil
        ) -> Self {
            .init(
                byEmail: byEmail ?? self.byEmail,
                byPhone: byPhone ?? self.byPhone,
                byUsername: byUsername ?? self.byUsername,
                withGoogle: withGoogle ?? self.withGoogle,
                error: error ?? self.error,
                success: success ?? self.success
            )
        }
    }

}

// MARK: - Reset Password Request View Context

extension Passage.Views {

    struct ResetPasswordRequestViewContext: Content {
        let error: String?
        let success: String?
    }

}

// MARK: - Reset Password Confirmation View Context

extension Passage.Views {

    struct ResetPasswordConfirmViewContext: Content {
        let code: String
        let email: String?
        let error: String?
        let success: String?
        let endpoint: String
    }

}
