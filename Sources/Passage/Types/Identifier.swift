public struct Identifier: Codable, Sendable, Equatable {

    public enum Kind: String, Codable, Sendable {
        case email
        case phone
        case username
        case federated
    }

    public let kind: Kind
    public let value: String
    public let provider: String?

}

// MARK: Convenience Initializers

public extension Identifier {

    static func email(_ email: String) -> Identifier {
        return Identifier(kind: .email, value: email, provider: nil)
    }

    static func phone(_ phone: String) -> Identifier {
        return Identifier(kind: .phone, value: phone, provider: nil)
    }

    static func username(_ username: String) -> Identifier {
        return Identifier(kind: .username, value: username, provider: nil)
    }

    static func federated(_ provider: String, userId: String) -> Identifier {
        return Identifier(kind: .federated, value: userId, provider: provider)
    }

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
        case .federated:
            return .federatedAccountAlreadyLinked
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
        case .federated:
            return .federatedLoginFailed
        }
    }

}
