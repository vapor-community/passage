//
//  Identifier.swift
//  passten
//
//  Created by Max Rozdobudko on 11/26/25.
//

struct Identifier {

    enum Kind: String, Codable {
        case email
        case phone
        case username
    }

    let kind: Kind
    let value: String

}

// MARK: Error Support

extension Identifier {

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
