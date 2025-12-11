import Vapor

public protocol RegisterForm: Form {
    var email: String? { get }
    var phone: String? { get }
    var username: String? { get }
    var password: String { get }
    var confirmPassword: String { get }

    func validate() throws
}

// MARK: - Register Form Extension

extension RegisterForm {

    func asIdentifier() throws -> Identifier {
        if let email = email {
            return .email(email)
        } else if let phone = phone {
            return .phone(phone)
        } else if let username = username {
            return .username(username)
        } else {
            throw AuthenticationError.identifierNotSpecified
        }
    }

}
