public struct Identifier: Codable, Sendable, Equatable {

    public enum Kind: String, Codable, Sendable {
        case email
        case phone
        case username
    }

    public let kind: Kind
    public let value: String

}

// MARK: Error Support

public extension Identifier {

    var errorWhenIdentifierAlreadyRegistered: AuthenticationError {
        return kind.errorWhenIdentifierAlreadyRegistered
    }

    var errorWhenIdentifierIsInvalid: AuthenticationError {
        return kind.errorWhenIdentifierIsInvalid
    }
}

extension Identifier.Kind {

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

}
