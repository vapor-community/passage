import Vapor

// MARK: - Email Magic Link Forms

/// Form for requesting a magic link to be sent to an email address
public protocol EmailMagicLinkRequestForm: Form {
    var email: String { get }
}

/// Form for verifying a magic link token
public protocol EmailMagicLinkVerifyForm: Form {
    var token: String { get }
}

/// Form for resending a magic link to an email address
public protocol EmailMagicLinkResendForm: Form {
    var email: String { get }
}

// MARK: - Default Implementations

extension Passage {

    struct DefaultEmailMagicLinkRequestForm: EmailMagicLinkRequestForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
        }

        let email: String
    }

    struct DefaultEmailMagicLinkVerifyForm: EmailMagicLinkVerifyForm {
        static func validations(_ validations: inout Validations) {
            validations.add("token", as: String.self, is: .count(32...64))
        }

        let token: String
    }

    struct DefaultEmailMagicLinkResendForm: EmailMagicLinkResendForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
        }

        let email: String
    }

}
