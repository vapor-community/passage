import Foundation

// MARK: - Store

public extension Passage {

    protocol Store: Sendable {
        var users: any UserStore { get }
        var tokens: any TokenStore { get }
        var verificationCodes: any VerificationCodeStore { get }
        var restorationCodes: any RestorationCodeStore { get }
        var magicLinkTokens: any MagicLinkTokenStore { get }
    }

}

// MARK: - User Store

public extension Passage {

    protocol UserStore: Sendable {
        associatedtype ConcreateUser: User
        var userType: ConcreateUser.Type { get }
        func create(with credential: Credential) async throws
        func find(byId id: String) async throws -> (any User)?
        func find(byCredential credential: Credential) async throws -> (any User)?
        func find(byIdentifier identifier: Identifier) async throws -> (any User)?
        func markEmailVerified(for user: any User) async throws
        func markPhoneVerified(for user: any User) async throws
        func setPassword(for user: any User, passwordHash: String) async throws

        /// Create a new user with just an email address (for passwordless flows)
        /// - Parameters:
        ///   - email: The email address for the new user
        ///   - verified: Whether the email should be marked as verified
        /// - Returns: The newly created user
        func createWithEmail(_ email: String, verified: Bool) async throws -> any User

        /// Create a new user with just a phone number (for passwordless flows)
        /// - Parameters:
        ///  - phone: The phone number for the new user
        ///  - verified: Whether the phone number should be marked as verified
        ///  - Returns: The newly created user
        func createWithPhone(_ phone: String, verified: Bool) async throws -> any User
    }

}

// MARK: - Token Store

public extension Passage {

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

}

// MARK: - Validation Code Store

public extension Passage {

    protocol VerificationCodeStore: Sendable {

        // MARK: Email Codes

        /// Create a new email verification code
        @discardableResult
        func createEmailCode(
            for user: any User,
            email: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any EmailVerificationCode

        /// Find email verification code by email and code hash
        func findEmailCode(
            forEmail email: String,
            codeHash: String
        ) async throws -> (any EmailVerificationCode)?

        /// Invalidate all pending codes for email
        func invalidateEmailCodes(forEmail email: String) async throws

        /// Increment failed attempt count for email code
        func incrementFailedAttempts(for code: any EmailVerificationCode) async throws

        // MARK: Phone Codes

        /// Create a new phone verification code
        @discardableResult
        func createPhoneCode(
            for user: any User,
            phone: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any PhoneVerificationCode

        /// Find phone verification code by phone and code hash
        func findPhoneCode(
            forPhone phone: String,
            codeHash: String
        ) async throws -> (any PhoneVerificationCode)?

        /// Invalidate all pending codes for phone
        func invalidatePhoneCodes(forPhone phone: String) async throws

        /// Increment failed attempt count for phone code
        func incrementFailedAttempts(for code: any PhoneVerificationCode) async throws
    }

}

// MARK: - Restoration Reset Code Store

public extension Passage {

    protocol RestorationCodeStore: Sendable {

        // MARK: Email Reset Codes

        /// Create a new email password reset code
        @discardableResult
        func createPasswordResetCode(
            for user: any User,
            email: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any EmailPasswordResetCode

        /// Find email reset code by email and code hash
        func findPasswordResetCode(
            forEmail email: String,
            codeHash: String
        ) async throws -> (any EmailPasswordResetCode)?

        /// Invalidate all pending reset codes for email
        func invalidatePasswordResetCodes(forEmail email: String) async throws

        /// Increment failed attempt count for email reset code
        func incrementFailedAttempts(for code: any EmailPasswordResetCode) async throws

        // MARK: Phone Reset Codes

        /// Create a new phone password reset code
        @discardableResult
        func createPasswordResetCode(
            for user: any User,
            phone: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any PhonePasswordResetCode

        /// Find phone reset code by phone and code hash
        func findPasswordResetCode(
            forPhone phone: String,
            codeHash: String
        ) async throws -> (any PhonePasswordResetCode)?

        /// Invalidate all pending reset codes for phone
        func invalidatePasswordResetCodes(forPhone phone: String) async throws

        /// Increment failed attempt count for phone reset code
        func incrementFailedAttempts(for code: any PhonePasswordResetCode) async throws
    }

}

// MARK: - Magic Link Code Store

public extension Passage {

    protocol MagicLinkTokenStore: Sendable {

        // MARK: Email Magic Links

        /// Create a new email magic link code
        /// - Parameters:
        ///   - user: The user associated with the magic link (nil for new users when auto-create is enabled)
        ///   - identifier: The identifier to send the magic link to (email, phone, etc.)
        ///   - tokenHash: SHA256 hash of the magic link token
        ///   - sessionTokenHash: SHA256 hash of the session token for same-browser verification (nil if not required)
        ///   - expiresAt: Expiration date for the magic link
        /// - Returns: The created magic link code
        @discardableResult
        func createEmailMagicLink(
            for user: (any User)?,
            identifier: Identifier,
            tokenHash: String,
            sessionTokenHash: String?,
            expiresAt: Date
        ) async throws -> any MagicLinkToken

        /// Find an email magic link by its token hash
        func findEmailMagicLink(tokenHash: String) async throws -> (any MagicLinkToken)?

        /// Invalidate all pending magic links for the given identifier
        func invalidateEmailMagicLinks(for identifier: Identifier) async throws

        /// Increment the failed attempt count for a magic link
        func incrementFailedAttempts(for magicLink: any MagicLinkToken) async throws
    }

}
