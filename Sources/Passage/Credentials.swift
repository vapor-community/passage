public enum Credential {
    case email(email: String, passwordHash: String)
    case phone(phone: String, passwordHash: String)
    case username(username: String, passwordHash: String)

    public var identifier: Identifier {
        return .init(kind: identifierKind, value: identifierValue)
    }

    var identifierKind: Identifier.Kind {
        switch self {
        case .email: return .email
        case .phone: return .phone
        case .username: return .username
        }
    }

    var identifierValue: String {
        switch self {
        case .email(email: let email, passwordHash: _):
            return email
        case .phone(phone: let phone, passwordHash: _):
            return phone
        case .username(username: let username, passwordHash: _):
            return username
        }
    }

    public var passwordHash: String {
        switch self {
        case .email(email: _, passwordHash: let passwordHash):
            return passwordHash
        case .phone(phone: _, passwordHash: let passwordHash):
            return passwordHash
        case .username(username: _, passwordHash: let passwordHash):
            return passwordHash
        }
    }
}

public extension Credential {

    var errorWhenIdentifierAlreadyRegistered: AuthenticationError {
        switch self {
        case .email:
            return .emailAlreadyRegistered
        case .phone:
            return .phoneAlreadyRegistered
        case .username:
            return .usernameAlreadyRegistered
        }
    }

    var errorWhenIdentifierIsInvalid: AuthenticationError {
        switch self {
        case .email:
            return .invalidEmailOrPassword
        case .phone:
            return .invalidPhoneOrPassword
        case .username:
            return .invalidUsernameOrPassword
        }
    }

    var errorWhenIdentifierNotVerified: AuthenticationError {
        switch self {
        case .email:
            return .emailIsNotVerified
        case .phone:
            return .phoneIsNotVerified
        case .username:
            // Username doesn't need verification, but we need to return something
            // This case should not be reached in normal flow
            return .invalidUsernameOrPassword
        }
    }

}
