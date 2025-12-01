import Foundation
import Vapor

// MARK: - Restoration Namespace

public extension Identity {

    /// Core service for orchestrating password reset flows.
    /// Supports both synchronous delivery and async via Vapor Queues.
    struct Restoration: Sendable {
        let request: Request
        let config: Identity.Configuration.Restoration
    }

}

extension Identity.Restoration {

    var store: any Identity.Store {
        request.store
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

    var restoration: Identity.Restoration {
        Identity.Restoration(
            request: self,
            config: configuration.restoration
        )
    }
}

// MARK: - Reset Code Protocols

public extension Identity.Restoration {

    /// Base protocol for password reset codes with common properties
    protocol Code: Sendable {
        associatedtype UserType: User

        var user: UserType { get }
        var codeHash: String { get }
        var expiresAt: Date { get }
        var failedAttempts: Int { get }
    }

    /// Represents a stored email password reset code
    protocol EmailResetCode: Code {
        var email: String { get }
    }

    /// Represents a stored phone password reset code
    protocol PhoneResetCode: Code {
        var phone: String { get }
    }

}

public extension Identity.Restoration.Code {

    var isExpired: Bool {
        Date() > expiresAt
    }

    func isValid(maxAttempts: Int) -> Bool {
        !isExpired && failedAttempts < maxAttempts
    }

}

// MARK: - Restoration Service

extension Identity.Restoration {

    /// Request password reset - send code based on identifier type
    func requestReset(for identifier: Identifier) async throws {
        // Find user by identifier
        guard let user = try await store.users.find(byIdentifier: identifier) else {
            throw AuthenticationError.restorationIdentifierNotFound
        }

        // Route to appropriate delivery based on identifier kind
        switch identifier.kind {
        case .email:
            try await sendEmailResetCode(to: user, email: identifier.value)
        case .phone:
            try await sendPhoneResetCode(to: user, phone: identifier.value)
        case .username:
            // Username requires fallback to preferred delivery channel
            try await sendResetCodeViaPreferredChannel(to: user)
        }
    }

    /// Verify reset code and set new password
    func verifyAndResetPassword(
        identifier: Identifier,
        code: String,
        newPasswordHash: String
    ) async throws {
        // Hash the code for comparison
        let codeHash = random.hashOpaqueToken(token: code)

        // Find and validate the code based on identifier type
        switch identifier.kind {
        case .email:
            try await verifyEmailResetCode(
                email: identifier.value,
                codeHash: codeHash,
                newPasswordHash: newPasswordHash
            )
        case .phone:
            try await verifyPhoneResetCode(
                phone: identifier.value,
                codeHash: codeHash,
                newPasswordHash: newPasswordHash
            )
        case .username:
            throw AuthenticationError.restorationDeliveryNotAvailable
        }
    }

    /// Resend email reset code
    func resendEmailResetCode(email: String) async throws {
        let identifier = Identifier(kind: .email, value: email)
        guard let user = try await store.users.find(byIdentifier: identifier) else {
            throw AuthenticationError.restorationIdentifierNotFound
        }
        try await sendEmailResetCode(to: user, email: email)
    }

    /// Resend phone reset code
    func resendPhoneResetCode(phone: String) async throws {
        let identifier = Identifier(kind: .phone, value: phone)
        guard let user = try await store.users.find(byIdentifier: identifier) else {
            throw AuthenticationError.restorationIdentifierNotFound
        }
        try await sendPhoneResetCode(to: user, phone: phone)
    }

    // MARK: - Private Methods

    private func sendEmailResetCode(to user: any User, email: String) async throws {
        guard emailDelivery != nil else {
            throw IdentityError.emailDeliveryNotConfigured
        }

        // Invalidate existing codes
        try await store.resetCodes.invalidateEmailResetCodes(forEmail: email)

        // Generate and store code
        let code = random.generateVerificationCode(length: config.email.codeLength)
        let hash = random.hashOpaqueToken(token: code)

        try await store.resetCodes.createEmailResetCode(
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

    private func sendPhoneResetCode(to user: any User, phone: String) async throws {
        guard phoneDelivery != nil else {
            throw IdentityError.phoneDeliveryNotConfigured
        }

        // Invalidate existing codes
        try await store.resetCodes.invalidatePhoneResetCodes(forPhone: phone)

        // Generate and store code
        let code = random.generateVerificationCode(length: config.phone.codeLength)
        let hash = random.hashOpaqueToken(token: code)

        try await store.resetCodes.createPhoneResetCode(
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

    private func sendResetCodeViaPreferredChannel(to user: any User) async throws {
        switch config.preferredDelivery {
        case .email:
            guard let email = user.email else {
                throw AuthenticationError.emailNotSet
            }
            try await sendEmailResetCode(to: user, email: email)
        case .phone:
            guard let phone = user.phone else {
                throw AuthenticationError.phoneNotSet
            }
            try await sendPhoneResetCode(to: user, phone: phone)
        }
    }

    private func verifyEmailResetCode(
        email: String,
        codeHash: String,
        newPasswordHash: String
    ) async throws {
        // Find the reset code
        guard let resetCode = try await store.resetCodes.findEmailResetCode(
            forEmail: email,
            codeHash: codeHash
        ) else {
            throw AuthenticationError.restorationCodeInvalid
        }

        // Check expiration
        if resetCode.isExpired {
            throw AuthenticationError.restorationCodeExpired
        }

        // Check max attempts
        if !resetCode.isValid(maxAttempts: config.email.maxAttempts) {
            throw AuthenticationError.restorationCodeMaxAttempts
        }

        // Update password
        try await store.users.setPassword(for: resetCode.user, passwordHash: newPasswordHash)

        // Invalidate all reset codes for this email
        try await store.resetCodes.invalidateEmailResetCodes(forEmail: email)

        // Revoke all refresh tokens (force re-login)
        try await store.tokens.revokeRefreshToken(for: resetCode.user)
    }

    private func verifyPhoneResetCode(
        phone: String,
        codeHash: String,
        newPasswordHash: String
    ) async throws {
        // Find the reset code
        guard let resetCode = try await store.resetCodes.findPhoneResetCode(
            forPhone: phone,
            codeHash: codeHash
        ) else {
            throw AuthenticationError.restorationCodeInvalid
        }

        // Check expiration
        if resetCode.isExpired {
            throw AuthenticationError.restorationCodeExpired
        }

        // Check max attempts
        if !resetCode.isValid(maxAttempts: config.phone.maxAttempts) {
            throw AuthenticationError.restorationCodeMaxAttempts
        }

        // Update password
        try await store.users.setPassword(for: resetCode.user, passwordHash: newPasswordHash)

        // Invalidate all reset codes for this phone
        try await store.resetCodes.invalidatePhoneResetCodes(forPhone: phone)

        // Revoke all refresh tokens (force re-login)
        try await store.tokens.revokeRefreshToken(for: resetCode.user)
    }

    // MARK: - Dispatch Methods

    private func dispatchEmailDelivery(email: String, code: String, userId: String) async throws {
        let resetURL = request.configuration.emailPasswordResetLinkURL(code: code, email: email)

        let payload = SendEmailResetCodePayload(
            email: email,
            userId: userId,
            resetURL: resetURL,
            resetCode: code
        )

        if config.useQueues {
            try await request.queue.dispatch(
                SendEmailResetCodeJob.self,
                payload,
                maxRetryCount: 3
            )
        } else {
            // Synchronous fallback
            guard let delivery = emailDelivery else { return }
            guard let user = try await store.users.find(byId: userId) else { return }
            try await delivery.sendPasswordResetEmail(
                to: email,
                user: user,
                passwordResetURL: resetURL,
                passwordResetCode: code,
            )
        }
    }

    private func dispatchPhoneDelivery(phone: String, code: String, userId: String) async throws {
        let payload = SendPhoneResetCodePayload(phone: phone, code: code, userId: userId)

        if config.useQueues {
            try await request.queue.dispatch(
                SendPhoneResetCodeJob.self,
                payload,
                maxRetryCount: 3
            )
        } else {
            guard let delivery = phoneDelivery else { return }
            guard let user = try await store.users.find(byId: userId) else { return }
            try await delivery.sendPasswordResetSMS(to: phone, code: code, user: user)
        }
    }
}
