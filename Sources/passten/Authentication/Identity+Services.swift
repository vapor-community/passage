//
//  Identity+Services.swift
//  passten
//
//  Created by Max Rozdobudko on 11/28/25.
//

import Foundation
import CryptoKit

extension Identity {

    struct Services: Sendable {
        let store: any Store
        let random: any RandomGenerator
        let emailDelivery: (any EmailDelivery)?
        let phoneDelivery: (any PhoneDelivery)?
        let federatedLogin: (any FederatedLoginService)?

        init(
            store: any Store,
            random: any RandomGenerator = DefaultRandomGenerator(),
            emailDelivery: (any EmailDelivery)?,
            phoneDelivery: (any PhoneDelivery)?,
            federatedLogin: (any FederatedLoginService)? = nil
        ) {
            self.store = store
            self.random = random
            self.emailDelivery = emailDelivery
            self.phoneDelivery = phoneDelivery
            self.federatedLogin = federatedLogin
        }
    }

}

extension Identity {

    var store: any Store {
        services.store
    }

    var random: any RandomGenerator {
        services.random
    }

    var emailDelivery: (any EmailDelivery)? {
        services.emailDelivery
    }

    var phoneDelivery: (any PhoneDelivery)? {
        services.phoneDelivery
    }
}

// MARK: - Store

extension Identity {

    protocol Store: Sendable {
        var users: any UserStore { get }
        var tokens: any TokenStore { get }
        var codes: any CodeStore { get }
    }

    protocol UserStore: Sendable {
        func create(with credential: Credential) async throws
        func find(byId id: String) async throws -> (any User)?
        func find(byCredential credential: Credential) async throws -> (any User)?
        func find(byIdentifier identifier: Identifier) async throws -> (any User)?
        func markEmailVerified(for user: any User) async throws
        func markPhoneVerified(for user: any User) async throws
    }

    protocol TokenStore: Sendable {
        @discardableResult
        func createRefreshToken(
            for user: any User,
            tokenHash hash: String,
            expiresAt: Date,
        ) async throws -> any RefreshToken

        @discardableResult
        func createRefreshToken(
            for user: any User,
            tokenHash hash: String,
            expiresAt: Date,
            replacing tokenToReplace: (any RefreshToken)?
        ) async throws -> any RefreshToken

        func find(refreshTokenHash hash: String) async throws -> (any RefreshToken)?
        func revokeRefreshToken(for user: any User) async throws
        func revokeRefreshToken(withHash hash: String) async throws
        func revoke(refreshTokenFamilyStartingFrom token: any RefreshToken) async throws
    }

    protocol CodeStore: Sendable {
        // MARK: - Email Codes

        /// Create a new email verification code
        @discardableResult
        func createEmailCode(
            for user: any User,
            email: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any Verification.EmailCode

        /// Find email verification code by email and code hash
        func findEmailCode(
            forEmail email: String,
            codeHash: String
        ) async throws -> (any Verification.EmailCode)?

        /// Invalidate all pending codes for email
        func invalidateEmailCodes(forEmail email: String) async throws

        /// Increment failed attempt count for email code
        func incrementFailedAttempts(for code: any Verification.EmailCode) async throws

        // MARK: - Phone Codes

        /// Create a new phone verification code
        @discardableResult
        func createPhoneCode(
            for user: any User,
            phone: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any Verification.PhoneCode

        /// Find phone verification code by phone and code hash
        func findPhoneCode(
            forPhone phone: String,
            codeHash: String
        ) async throws -> (any Verification.PhoneCode)?

        /// Invalidate all pending codes for phone
        func invalidatePhoneCodes(forPhone phone: String) async throws

        /// Increment failed attempt count for phone code
        func incrementFailedAttempts(for code: any Verification.PhoneCode) async throws
    }

}

// MARK: - Random

extension Identity {
    protocol RandomGenerator: Sendable {
        func generateRandomString(count: Int) -> String
        func generateOpaqueToken() -> String
        func hashOpaqueToken(token: String) -> String
        func generateVerificationCode(length: Int) -> String
    }
}

struct DefaultRandomGenerator: Identity.RandomGenerator {
    func generateRandomString(count: Int) -> String {
        Data([UInt8].random(count: count)).base64EncodedString()
    }
    func generateOpaqueToken() -> String {
        generateRandomString(count: 32)
    }
    func hashOpaqueToken(token: String) -> String {
        SHA256.hash(data: Data(token.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
    func generateVerificationCode(length: Int) -> String {
        // Alphanumeric characters excluding confusing ones (0/O, 1/I/L)
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
}

// MARK: - Federated Login
