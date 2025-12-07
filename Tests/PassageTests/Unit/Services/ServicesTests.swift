import Testing
import Foundation
@testable import Passage

@Suite("Services Tests")
struct ServicesTests {

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

    struct MockUserStore: Passage.UserStore {
        typealias ConcreateUser = MockUser
        var userType: MockUser.Type { MockUser.self }
        func create(with credential: Credential) async throws {}
        func find(byId id: String) async throws -> (any User)? { nil }
        func find(byCredential credential: Credential) async throws -> (any User)? { nil }
        func find(byIdentifier identifier: Identifier) async throws -> (any User)? { nil }
        func markEmailVerified(for user: any User) async throws {}
        func markPhoneVerified(for user: any User) async throws {}
        func setPassword(for user: any User, passwordHash: String) async throws {}
        func createWithEmail(_ email: String, verified: Bool) async throws -> any User {
            MockUser(id: UUID(), email: email, phone: nil, username: nil, passwordHash: nil, isAnonymous: false, isEmailVerified: verified, isPhoneVerified: false)
        }
        func createWithPhone(_ phone: String, verified: Bool) async throws -> any User {
            MockUser(id: UUID(), email: nil, phone: phone, username: nil, passwordHash: nil, isAnonymous: false, isEmailVerified: false, isPhoneVerified: verified)
        }
    }

    struct MockTokenStore: Passage.TokenStore {
        func createRefreshToken(for user: any User, tokenHash hash: String, expiresAt: Date) async throws -> any RefreshToken {
            fatalError()
        }
        func createRefreshToken(for user: any User, tokenHash hash: String, expiresAt: Date, replacing tokenToReplace: (any RefreshToken)?) async throws -> any RefreshToken {
            fatalError()
        }
        func find(refreshTokenHash hash: String) async throws -> (any RefreshToken)? { nil }
        func revokeRefreshToken(for user: any User) async throws {}
        func revokeRefreshToken(withHash hash: String) async throws {}
        func revoke(refreshTokenFamilyStartingFrom token: any RefreshToken) async throws {}
    }

    struct MockVerificationCodeStore: Passage.VerificationCodeStore {
        func createEmailCode(for user: any User, email: String, codeHash: String, expiresAt: Date) async throws -> any EmailVerificationCode { fatalError() }
        func findEmailCode(forEmail email: String, codeHash: String) async throws -> (any EmailVerificationCode)? { nil }
        func invalidateEmailCodes(forEmail email: String) async throws {}
        func incrementFailedAttempts(for code: any EmailVerificationCode) async throws {}
        func createPhoneCode(for user: any User, phone: String, codeHash: String, expiresAt: Date) async throws -> any PhoneVerificationCode { fatalError() }
        func findPhoneCode(forPhone phone: String, codeHash: String) async throws -> (any PhoneVerificationCode)? { nil }
        func invalidatePhoneCodes(forPhone phone: String) async throws {}
        func incrementFailedAttempts(for code: any PhoneVerificationCode) async throws {}
    }

    struct MockRestorationCodeStore: Passage.RestorationCodeStore {
        func createPasswordResetCode(for user: any User, email: String, codeHash: String, expiresAt: Date) async throws -> any EmailPasswordResetCode { fatalError() }
        func findPasswordResetCode(forEmail email: String, codeHash: String) async throws -> (any EmailPasswordResetCode)? { nil }
        func invalidatePasswordResetCodes(forEmail email: String) async throws {}
        func incrementFailedAttempts(for code: any EmailPasswordResetCode) async throws {}
        func createPasswordResetCode(for user: any User, phone: String, codeHash: String, expiresAt: Date) async throws -> any PhonePasswordResetCode { fatalError() }
        func findPasswordResetCode(forPhone phone: String, codeHash: String) async throws -> (any PhonePasswordResetCode)? { nil }
        func invalidatePasswordResetCodes(forPhone phone: String) async throws {}
        func incrementFailedAttempts(for code: any PhonePasswordResetCode) async throws {}
    }

    struct MockMagicLinkTokenStore: Passage.MagicLinkTokenStore {
        func createEmailMagicLink(for user: (any User)?, identifier: Identifier, tokenHash: String, sessionTokenHash: String?, expiresAt: Date) async throws -> any MagicLinkToken { fatalError() }
        func findEmailMagicLink(tokenHash: String) async throws -> (any MagicLinkToken)? { nil }
        func invalidateEmailMagicLinks(for identifier: Identifier) async throws {}
        func incrementFailedAttempts(for magicLink: any MagicLinkToken) async throws {}
    }

    struct MockStore: Passage.Store {
        var users: any Passage.UserStore { MockUserStore() }
        var tokens: any Passage.TokenStore { MockTokenStore() }
        var verificationCodes: any Passage.VerificationCodeStore { MockVerificationCodeStore() }
        var restorationCodes: any Passage.RestorationCodeStore { MockRestorationCodeStore() }
        var magicLinkTokens: any Passage.MagicLinkTokenStore { MockMagicLinkTokenStore() }
    }

    struct MockEmailDelivery: Passage.EmailDelivery {
        func sendEmailVerification(to email: String, user: any User, verificationURL: URL, verificationCode: String) async throws {}
        func sendEmailVerificationConfirmation(to email: String, user: any User) async throws {}
        func sendPasswordResetEmail(to email: String, user: any User, passwordResetURL: URL, passwordResetCode: String) async throws {}
        func sendWelcomeEmail(to email: String, user: any User) async throws {}
        func sendMagicLinkEmail(to email: String, user: (any User)?, magicLinkURL: URL) async throws {}
    }

    struct MockPhoneDelivery: Passage.PhoneDelivery {
        func sendPhoneVerification(to phone: String, code: String, user: any User) async throws {}
        func sendVerificationConfirmation(to phone: String, user: any User) async throws {}
        func sendPasswordResetSMS(to phone: String, code: String, user: any User) async throws {}
    }

    struct MockRandomGenerator: Passage.RandomGenerator {
        func generateRandomString(count: Int) -> String { "random" }
        func generateOpaqueToken() -> String { "token" }
        func hashOpaqueToken(token: String) -> String { "hash" }
        func generateVerificationCode(length: Int) -> String { "123456" }
    }

    // MARK: - Services Initialization Tests

    @Test("Services initialization with all parameters")
    func servicesInitializationFull() {
        let store = MockStore()
        let random = MockRandomGenerator()
        let emailDelivery = MockEmailDelivery()
        let phoneDelivery = MockPhoneDelivery()

        let services = Passage.Services(
            store: store,
            random: random,
            emailDelivery: emailDelivery,
            phoneDelivery: phoneDelivery,
            federatedLogin: nil
        )

        #expect(services.store is MockStore)
        #expect(services.random is MockRandomGenerator)
        #expect(services.emailDelivery != nil)
        #expect(services.phoneDelivery != nil)
        #expect(services.federatedLogin == nil)
    }

    @Test("Services initialization with default random generator")
    func servicesInitializationWithDefaultRandom() {
        let store = MockStore()
        let emailDelivery = MockEmailDelivery()
        let phoneDelivery = MockPhoneDelivery()

        let services = Passage.Services(
            store: store,
            emailDelivery: emailDelivery,
            phoneDelivery: phoneDelivery,
            federatedLogin: nil
        )

        #expect(services.store is MockStore)
        #expect(services.random is DefaultRandomGenerator)
        #expect(services.emailDelivery != nil)
        #expect(services.phoneDelivery != nil)
    }

    @Test("Services with nil email delivery")
    func servicesWithNilEmailDelivery() {
        let store = MockStore()
        let random = MockRandomGenerator()

        let services = Passage.Services(
            store: store,
            random: random,
            emailDelivery: nil,
            phoneDelivery: nil
        )

        #expect(services.emailDelivery == nil)
        #expect(services.phoneDelivery == nil)
    }

    @Test("Services conforms to Sendable")
    func servicesIsSendable() {
        let store = MockStore()
        let random = MockRandomGenerator()

        let services: any Sendable = Passage.Services(
            store: store,
            random: random,
            emailDelivery: nil,
            phoneDelivery: nil
        )

        #expect(services is Passage.Services)
    }

    // MARK: - DeliveryType Tests

    @Test("DeliveryType enum has email case")
    func deliveryTypeEmail() {
        let deliveryType = Passage.DeliveryType.email
        #expect(deliveryType == .email)
    }

    @Test("DeliveryType enum has phone case")
    func deliveryTypePhone() {
        let deliveryType = Passage.DeliveryType.phone
        #expect(deliveryType == .phone)
    }

    @Test("DeliveryType conforms to Sendable")
    func deliveryTypeIsSendable() {
        let deliveryType: any Sendable = Passage.DeliveryType.email
        #expect(deliveryType is Passage.DeliveryType)
    }

    @Test("DeliveryType cases are distinct")
    func deliveryTypeCasesAreDistinct() {
        let email = Passage.DeliveryType.email
        let phone = Passage.DeliveryType.phone
        #expect(email != phone)
    }

    // MARK: - Services Properties Access Tests

    @Test("Services stores references correctly")
    func servicesStoresReferences() {
        let store = MockStore()
        let random = MockRandomGenerator()
        let emailDelivery = MockEmailDelivery()

        let services = Passage.Services(
            store: store,
            random: random,
            emailDelivery: emailDelivery,
            phoneDelivery: nil
        )

        #expect(services.store is MockStore)
        #expect(services.random is MockRandomGenerator)
        #expect(services.emailDelivery is MockEmailDelivery)
    }
}
