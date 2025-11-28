//
//  Identity+Verification.swift
//  passten
//
//  Created by Max Rozdobudko on 11/28/25.
//

import Foundation

// MARK: - Verification Namespace

extension Identity {

    /// Core service for orchestrating verification flows.
    /// Supports both synchronous delivery and async via Vapor Queues.
    struct Verification: Sendable {
        let request: Request
        let config: Identity.Configuration.Verification
    }

}

extension Identity.Verification {

    var store: any Identity.Store {
        get throws {
            try request.store
        }
    }

    var random: any Identity.RandomGenerator {
        request.random
    }

    var emailDelivery: (any Identity.EmailDelivery)? {
        request.emailDelivery
    }

    var phoneDelivery: (any Identity.PhoneDelivery)? {
        request.phoneDelivery
    }

}

extension Request {

    var verification: Identity.Verification {
        Identity.Verification(
            request: self,
            config: configuration.verification
        )
    }
}


// MARK: - Email Delivery Protocol

extension Identity {

    /// Protocol for sending verification emails.
    /// Implementations handle template selection and delivery.
    protocol EmailDelivery: Sendable {
        /// Send a verification code email
        func sendVerificationEmail(
            to email: String,
            code: String,
            user: any User
        ) async throws

        /// Send password reset email
        func sendPasswordResetEmail(
            to email: String,
            code: String,
            user: any User
        ) async throws

        /// Send welcome email after registration
        func sendWelcomeEmail(
            to email: String,
            user: any User
        ) async throws

        /// Send email verification success confirmation
        func sendVerificationConfirmation(
            to email: String,
            user: any User
        ) async throws
    }

}

// MARK: - Phone Delivery Protocol

extension Identity {

    /// Protocol for sending verification SMS/calls.
    /// Implementations handle message formatting and delivery.
    protocol PhoneDelivery: Sendable {
        /// Send a verification code via SMS
        func sendVerificationSMS(
            to phone: String,
            code: String,
            user: any User
        ) async throws

        /// Send password reset code via SMS
        func sendPasswordResetSMS(
            to phone: String,
            code: String,
            user: any User
        ) async throws

        /// Send verification success confirmation
        func sendVerificationConfirmation(
            to phone: String,
            user: any User
        ) async throws
    }

}

// MARK: - Verification Code Protocols

extension Identity.Verification {

    /// Base protocol for verification codes with common properties
    protocol Code: Sendable {
        associatedtype UserType: User

        var user: UserType { get }
        var codeHash: String { get }
        var expiresAt: Date { get }
        var failedAttempts: Int { get }
    }

    /// Represents a stored email verification code
    protocol EmailCode: Code {
        var email: String { get }
    }

    /// Represents a stored phone verification code
    protocol PhoneCode: Code {
        var phone: String { get }
    }

}

extension Identity.Verification.Code {

    var isExpired: Bool {
        Date() > expiresAt
    }

    func isValid(maxAttempts: Int) -> Bool {
        !isExpired && failedAttempts < maxAttempts
    }

}

// MARK: - Verification Service

import Vapor

extension Identity.Verification {

    /// Send email verification code to a user.
    /// Code is generated and stored synchronously.
    /// Delivery is dispatched to queue if available, otherwise sent synchronously.
    func sendEmailCode(to user: any User) async throws {
        guard emailDelivery != nil else {
            throw IdentityError.emailDeliveryNotConfigured
        }

        guard let email = user.email else {
            throw AuthenticationError.emailNotSet
        }

        // Invalidate existing codes
        try await store.codes.invalidateEmailCodes(forEmail: email)

        // Generate and store code (synchronous - needed before response)
        let code = random.generateVerificationCode(length: config.email.codeLength)
        let hash = random.hashOpaqueToken(token: code)

        try await store.codes.createEmailCode(
            for: user,
            email: email,
            codeHash: hash,
            expiresAt: Date().addingTimeInterval(config.email.codeExpiration)
        )

        // Dispatch delivery (queue or sync)
        try await dispatchEmailDelivery(
            email: email,
            code: code,
            userId: try user.requiredIdAsString
        )
    }

    /// Send phone verification code to a user.
    func sendPhoneCode(to user: any User) async throws {
        guard phoneDelivery != nil else {
            throw IdentityError.phoneDeliveryNotConfigured
        }

        guard let phone = user.phone else {
            throw AuthenticationError.phoneNotSet
        }

        // Invalidate existing codes
        try await store.codes.invalidatePhoneCodes(forPhone: phone)

        // Generate and store code
        let code = random.generateVerificationCode(length: config.phone.codeLength)
        let hash = random.hashOpaqueToken(token: code)

        try await store.codes.createPhoneCode(
            for: user,
            phone: phone,
            codeHash: hash,
            expiresAt: Date().addingTimeInterval(config.phone.codeExpiration)
        )

        // Dispatch delivery (queue or sync)
        try await dispatchPhoneDelivery(
            phone: phone,
            code: code,
            userId: try user.requiredIdAsString
        )
    }

    /// Send verification code based on identifier kind.
    func sendVerificationCode(for user: any User, identifierKind: Identifier.Kind) async throws {
        switch identifierKind {
        case .email:
            try await sendEmailCode(to: user)
        case .phone:
            try await sendPhoneCode(to: user)
        case .username:
            break // Username doesn't require verification
        }
    }

    // MARK: - Private Dispatch Methods

    private func dispatchEmailDelivery(email: String, code: String, userId: String) async throws {
        let payload = SendEmailCodePayload(email: email, code: code, userId: userId)

        if config.useQueues {
            try await request.queue.dispatch(
                SendEmailCodeJob.self,
                payload,
                maxRetryCount: 3
            )
        } else {
            // Synchronous fallback
            guard let delivery = emailDelivery else { return }
            guard let user = try await store.users.find(byId: userId) else { return }
            try await delivery.sendVerificationEmail(to: email, code: code, user: user)
        }
    }

    private func dispatchPhoneDelivery(phone: String, code: String, userId: String) async throws {
        let payload = SendPhoneCodePayload(phone: phone, code: code, userId: userId)

        if config.useQueues {
            try await request.queue.dispatch(
                SendPhoneCodeJob.self,
                payload,
                maxRetryCount: 3
            )
        } else {
            guard let delivery = phoneDelivery else { return }
            guard let user = try await store.users.find(byId: userId) else { return }
            try await delivery.sendVerificationSMS(to: phone, code: code, user: user)
        }
    }
}
