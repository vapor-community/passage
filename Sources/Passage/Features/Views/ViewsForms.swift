import Vapor

// MARK: - Login Form



// MARK: - Password Reset Request Form

struct PasswordResetRequestForm: Content {
    let email: String?
    let phone: String?
}

extension PasswordResetRequestForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String?.self, is: .email || .nil, required: false)
        validations.add("phone", as: String?.self, is: !.empty || .nil, required: false)
    }

    func validate() throws {
        if email == nil && phone == nil {
            throw Abort(.badRequest, reason: "Either email or phone must be provided.")
        }
    }
}

extension PasswordResetRequestForm {
    func asIdentifier() throws -> Identifier {
        if let email = email {
            return .email(email)
        } else if let phone = phone {
            return .phone(phone)
        } else {
            throw AuthenticationError.identifierNotSpecified
        }
    }
}

// MARK: - Password Reset Confirm Form

struct PasswordResetConfirmForm: Content {
    let email: String?
    let phone: String?
    let code: String
    let newPassword: String
    let confirmPassword: String
}

extension PasswordResetConfirmForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String?.self, is: .email || .nil, required: false)
        validations.add("phone", as: String?.self, is: !.empty || .nil, required: false)
        validations.add("code", as: String.self, is: !.empty)
        validations.add("newPassword", as: String.self, is: .count(8...))
        validations.add("confirmPassword", as: String.self, is: .count(8...))
    }

    func validate() throws {
        if email == nil && phone == nil {
            throw Abort(.badRequest, reason: "Either email or phone must be provided.")
        }
        if newPassword != confirmPassword {
            throw Abort(.badRequest, reason: "New password and confirm password do not match.")
        }
    }
}

extension PasswordResetConfirmForm {
    func asIdentifier() throws -> Identifier {
        if let email = email {
            return .email(email)
        } else if let phone = phone {
            return .phone(phone)
        } else {
            throw AuthenticationError.identifierNotSpecified
        }
    }
}
