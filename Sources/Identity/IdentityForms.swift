import Vapor

// MARK: - Register Form

struct RegisterForm: Content {
    let email: String?
    let phone: String?
    let username: String?
    let password: String
    let confirmPassword: String
}

extension RegisterForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String?.self, is: .email || .nil, required: false)
        validations.add("password", as: String.self, is: .count(6...))
        validations.add("confirmPassword", as: String.self, is: .count(6...))
    }

    func validate() throws {
        if password != confirmPassword {
            throw AuthenticationError.passwordsDoNotMatch
        }
    }
}

extension RegisterForm {

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

// MARK: - Login Form

struct LoginForm: Content {
    let email: String?
    let phone: String?
    let username: String?
    let password: String
}

extension LoginForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String?.self, is: .email || .nil, required: false)
        validations.add("password", as: String.self, is: .count(6...))
    }
}

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

// MARK: - Refresh Token Form

struct RefreshTokenForm: Content {
    let refreshToken: String
}

// MARK: - AuthUser

struct AuthUser: Content {
    struct User: Content, UserInfo {
        let id: String
        let email: String?
        let phone: String?
    }

    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: TimeInterval
    let user: User
}
