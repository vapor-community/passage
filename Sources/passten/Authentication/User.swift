//
//  User.swift
//  passten
//
//  Created by Max Rozdobudko on 11/25/25.
//

import Vapor

// MARK: - User

protocol User: Authenticatable, Sendable {
    associatedtype Id: CustomStringConvertible, Codable, Hashable, Sendable

    var id: Id? { get }

    var email: String? { get }

    var phone: String? { get }

    var username: String? { get }

    var passwordHash: String? { get }

    var isAnonymous: Bool { get }

    var isEmailVerified: Bool { get }

    var isPhoneVerified: Bool { get }
}

extension User {

    var requiredIdAsString: String {
        get throws {
            guard let id = id else {
                throw IdentityError.unexpected(message: "User ID is missing")
            }
            return String(describing: id)
        }
    }

}

extension User {

    func check(identifier: Identifier) throws {
        switch identifier.kind {
        case .email:
            guard isEmailVerified else {
                throw AuthenticationError.emailIsNotVerified
            }
        case .phone:
            guard isPhoneVerified else {
                throw AuthenticationError.phoneIsNotVerified
            }
        case .username:
            break
        }
    }
}

// MARK: - User Info

protocol UserInfo: Sendable {

    var email: String? { get }

    var phone: String? { get }

}

