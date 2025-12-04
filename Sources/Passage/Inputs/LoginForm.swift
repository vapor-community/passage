import Vapor

public protocol LoginForm: Form {
    var email: String? { get }
    var phone: String? { get }
    var username: String? { get }
    var password: String { get }

    func validate() throws
}

// MARK: - Login Form Extension

extension LoginForm {

    func asIdentifier() throws -> Identifier {
        if let email = email {
            return .init(kind: .email, value: email)
        } else if let phone = phone {
            return .init(kind: .phone, value: phone)
        } else if let username = username {
            return .init(kind: .username, value: username)
        } else {
            throw AuthenticationError.identifierNotSpecified
        }
    }

    func asCredential(hash: String) throws -> Credential {
        if let email = email {
            return .email(email: email, passwordHash: hash)
        } else if let phone = phone {
            return .phone(phone: phone, passwordHash: hash)
        } else if let username = username {
            return .username(username: username, passwordHash: hash)
        } else {
            throw AuthenticationError.identifierNotSpecified
        }
    }

}
