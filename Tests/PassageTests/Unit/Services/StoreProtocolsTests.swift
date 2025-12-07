import Testing
import Foundation
@testable import Passage

@Suite("Store Protocols Tests")
struct StoreProtocolsTests {

    // MARK: - Mock Implementations

    struct MockUser: User {
        typealias Id = UUID
        var id: UUID?
        var email: String?
        var phone: String?
        var username: String?
        var passwordHash: String?
        var isAnonymous: Bool
        var isEmailVerified: Bool
        var isPhoneVerified: Bool
    }

    struct MockRefreshToken: RefreshToken {
        typealias Id = UUID
        typealias AssociatedUser = MockUser
        var id: UUID?
        var user: MockUser
        var tokenHash: String
        var expiresAt: Date
        var revokedAt: Date?
        var replacedBy: UUID?
    }

    struct MockEmailVerificationCode: EmailVerificationCode {
        typealias AssociatedUser = MockUser
        var user: MockUser
        var codeHash: String
        var expiresAt: Date
        var failedAttempts: Int
        var email: String
    }

    struct MockPhoneVerificationCode: PhoneVerificationCode {
        typealias AssociatedUser = MockUser
        var user: MockUser
        var codeHash: String
        var expiresAt: Date
        var failedAttempts: Int
        var phone: String
    }

    struct MockEmailPasswordResetCode: EmailPasswordResetCode {
        typealias AssociatedUser = MockUser
        var user: MockUser
        var codeHash: String
        var expiresAt: Date
        var failedAttempts: Int
        var email: String
    }

    struct MockPhonePasswordResetCode: PhonePasswordResetCode {
        typealias AssociatedUser = MockUser
        var user: MockUser
        var codeHash: String
        var expiresAt: Date
        var failedAttempts: Int
        var phone: String
    }

    // MARK: - UserStore Protocol Tests

    struct MockUserStore: Passage.UserStore {

        typealias ConcreateUser = MockUser
        var userType: MockUser.Type { MockUser.self }

        func create(with credential: Credential) async throws {
            // Method signature test
        }

        func find(byId id: String) async throws -> (any User)? {
            nil
        }

        func find(byCredential credential: Credential) async throws -> (any User)? {
            nil
        }

        func find(byIdentifier identifier: Identifier) async throws -> (any User)? {
            nil
        }

        func markEmailVerified(for user: any User) async throws {
            // Method signature test
        }

        func markPhoneVerified(for user: any User) async throws {
            // Method signature test
        }

        func setPassword(for user: any User, passwordHash: String) async throws {
            // Method signature test
        }

        func createWithEmail(_ email: String, verified: Bool) async throws -> any User {
            MockUser(id: UUID(), email: email, phone: nil, username: nil, passwordHash: nil, isAnonymous: false, isEmailVerified: verified, isPhoneVerified: false)
        }

        func createWithPhone(_ phone: String, verified: Bool) async throws -> any User {
            MockUser(id: UUID(), email: nil, phone: phone, username: nil, passwordHash: nil, isAnonymous: false, isEmailVerified: false, isPhoneVerified: verified)
        }
    }

    @Test("UserStore protocol can be implemented")
    func userStoreProtocolImplementation() {
        let store: any Passage.UserStore = MockUserStore()
        #expect(store.userType is MockUser.Type)
    }

    @Test("UserStore protocol conforms to Sendable")
    func userStoreProtocolIsSendable() {
        let store: any Sendable = MockUserStore()
        #expect(store is MockUserStore)
    }

    // MARK: - TokenStore Protocol Tests

    struct MockTokenStore: Passage.TokenStore {
        func createRefreshToken(
            for user: any User,
            tokenHash hash: String,
            expiresAt: Date
        ) async throws -> any RefreshToken {
            MockRefreshToken(
                id: UUID(),
                user: user as! MockUser,
                tokenHash: hash,
                expiresAt: expiresAt,
                revokedAt: nil,
                replacedBy: nil
            )
        }

        func createRefreshToken(
            for user: any User,
            tokenHash hash: String,
            expiresAt: Date,
            replacing tokenToReplace: (any RefreshToken)?
        ) async throws -> any RefreshToken {
            MockRefreshToken(
                id: UUID(),
                user: user as! MockUser,
                tokenHash: hash,
                expiresAt: expiresAt,
                revokedAt: nil,
                replacedBy: tokenToReplace?.id as? UUID
            )
        }

        func find(refreshTokenHash hash: String) async throws -> (any RefreshToken)? {
            nil
        }

        func revokeRefreshToken(for user: any User) async throws {
            // Method signature test
        }

        func revokeRefreshToken(withHash hash: String) async throws {
            // Method signature test
        }

        func revoke(refreshTokenFamilyStartingFrom token: any RefreshToken) async throws {
            // Method signature test
        }
    }

    @Test("TokenStore protocol can be implemented")
    func tokenStoreProtocolImplementation() {
        let store: any Passage.TokenStore = MockTokenStore()
        #expect(store is MockTokenStore)
    }

    @Test("TokenStore protocol conforms to Sendable")
    func tokenStoreProtocolIsSendable() {
        let store: any Sendable = MockTokenStore()
        #expect(store is MockTokenStore)
    }

    // MARK: - VerificationCodeStore Protocol Tests

    struct MockVerificationCodeStore: Passage.VerificationCodeStore {
        func createEmailCode(
            for user: any User,
            email: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any EmailVerificationCode {
            MockEmailVerificationCode(
                user: user as! MockUser,
                codeHash: codeHash,
                expiresAt: expiresAt,
                failedAttempts: 0,
                email: email
            )
        }

        func findEmailCode(
            forEmail email: String,
            codeHash: String
        ) async throws -> (any EmailVerificationCode)? {
            nil
        }

        func invalidateEmailCodes(forEmail email: String) async throws {
            // Method signature test
        }

        func incrementFailedAttempts(for code: any EmailVerificationCode) async throws {
            // Method signature test
        }

        func createPhoneCode(
            for user: any User,
            phone: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any PhoneVerificationCode {
            MockPhoneVerificationCode(
                user: user as! MockUser,
                codeHash: codeHash,
                expiresAt: expiresAt,
                failedAttempts: 0,
                phone: phone
            )
        }

        func findPhoneCode(
            forPhone phone: String,
            codeHash: String
        ) async throws -> (any PhoneVerificationCode)? {
            nil
        }

        func invalidatePhoneCodes(forPhone phone: String) async throws {
            // Method signature test
        }

        func incrementFailedAttempts(for code: any PhoneVerificationCode) async throws {
            // Method signature test
        }
    }

    @Test("VerificationCodeStore protocol can be implemented")
    func verificationCodeStoreProtocolImplementation() {
        let store: any Passage.VerificationCodeStore = MockVerificationCodeStore()
        #expect(store is MockVerificationCodeStore)
    }

    @Test("VerificationCodeStore protocol conforms to Sendable")
    func verificationCodeStoreProtocolIsSendable() {
        let store: any Sendable = MockVerificationCodeStore()
        #expect(store is MockVerificationCodeStore)
    }

    // MARK: - RestorationCodeStore Protocol Tests

    struct MockRestorationCodeStore: Passage.RestorationCodeStore {
        func createPasswordResetCode(
            for user: any User,
            email: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any EmailPasswordResetCode {
            MockEmailPasswordResetCode(
                user: user as! MockUser,
                codeHash: codeHash,
                expiresAt: expiresAt,
                failedAttempts: 0,
                email: email
            )
        }

        func findPasswordResetCode(
            forEmail email: String,
            codeHash: String
        ) async throws -> (any EmailPasswordResetCode)? {
            nil
        }

        func invalidatePasswordResetCodes(forEmail email: String) async throws {
            // Method signature test
        }

        func incrementFailedAttempts(for code: any EmailPasswordResetCode) async throws {
            // Method signature test
        }

        func createPasswordResetCode(
            for user: any User,
            phone: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any PhonePasswordResetCode {
            MockPhonePasswordResetCode(
                user: user as! MockUser,
                codeHash: codeHash,
                expiresAt: expiresAt,
                failedAttempts: 0,
                phone: phone
            )
        }

        func findPasswordResetCode(
            forPhone phone: String,
            codeHash: String
        ) async throws -> (any PhonePasswordResetCode)? {
            nil
        }

        func invalidatePasswordResetCodes(forPhone phone: String) async throws {
            // Method signature test
        }

        func incrementFailedAttempts(for code: any PhonePasswordResetCode) async throws {
            // Method signature test
        }
    }

    @Test("RestorationCodeStore protocol can be implemented")
    func restorationCodeStoreProtocolImplementation() {
        let store: any Passage.RestorationCodeStore = MockRestorationCodeStore()
        #expect(store is MockRestorationCodeStore)
    }

    @Test("RestorationCodeStore protocol conforms to Sendable")
    func restorationCodeStoreProtocolIsSendable() {
        let store: any Sendable = MockRestorationCodeStore()
        #expect(store is MockRestorationCodeStore)
    }

    // MARK: - MagicLinkTokenStore Protocol Tests

    struct MockMagicLinkToken: MagicLinkToken {
        typealias AssociatedUser = MockUser
        var user: MockUser?
        var identifier: Identifier
        var tokenHash: String
        var sessionTokenHash: String?
        var expiresAt: Date
        var failedAttempts: Int
    }

    struct MockMagicLinkTokenStore: Passage.MagicLinkTokenStore {
        func createEmailMagicLink(for user: (any User)?, identifier: Identifier, tokenHash: String, sessionTokenHash: String?, expiresAt: Date) async throws -> any MagicLinkToken {
            MockMagicLinkToken(user: user as? MockUser, identifier: identifier, tokenHash: tokenHash, sessionTokenHash: sessionTokenHash, expiresAt: expiresAt, failedAttempts: 0)
        }
        func findEmailMagicLink(tokenHash: String) async throws -> (any MagicLinkToken)? { nil }
        func invalidateEmailMagicLinks(for identifier: Identifier) async throws {}
        func incrementFailedAttempts(for magicLink: any MagicLinkToken) async throws {}
    }

    @Test("MagicLinkTokenStore protocol can be implemented")
    func magicLinkTokenStoreProtocolImplementation() {
        let store: any Passage.MagicLinkTokenStore = MockMagicLinkTokenStore()
        #expect(store is MockMagicLinkTokenStore)
    }

    @Test("MagicLinkTokenStore protocol conforms to Sendable")
    func magicLinkTokenStoreProtocolIsSendable() {
        let store: any Sendable = MockMagicLinkTokenStore()
        #expect(store is MockMagicLinkTokenStore)
    }

    // MARK: - Store Protocol Tests

    struct MockStore: Passage.Store {
        var users: any Passage.UserStore { MockUserStore() }
        var tokens: any Passage.TokenStore { MockTokenStore() }
        var verificationCodes: any Passage.VerificationCodeStore { MockVerificationCodeStore() }
        var restorationCodes: any Passage.RestorationCodeStore { MockRestorationCodeStore() }
        var magicLinkTokens: any Passage.MagicLinkTokenStore { MockMagicLinkTokenStore() }
    }

    @Test("Store protocol can be implemented")
    func storeProtocolImplementation() {
        let store: any Passage.Store = MockStore()
        #expect(store is MockStore)
    }

    @Test("Store protocol conforms to Sendable")
    func storeProtocolIsSendable() {
        let store: any Sendable = MockStore()
        #expect(store is MockStore)
    }

    @Test("Store protocol provides access to all sub-stores")
    func storeProtocolSubStoresAccess() {
        let store: any Passage.Store = MockStore()

        #expect(store.users is MockUserStore)
        #expect(store.tokens is MockTokenStore)
        #expect(store.verificationCodes is MockVerificationCodeStore)
        #expect(store.restorationCodes is MockRestorationCodeStore)
        #expect(store.magicLinkTokens is MockMagicLinkTokenStore)
    }
}
