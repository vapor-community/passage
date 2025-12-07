import Testing
import Foundation
import Vapor
@testable import Passage

@Suite("Delivery Protocols Tests")
struct DeliveryProtocolsTests {

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

    // MARK: - EmailDelivery Protocol Tests

    struct MockEmailDelivery: Passage.EmailDelivery {
        var sentEmails: [String] = []

        func sendEmailVerification(
            to email: String,
            user: any User,
            verificationURL: URL,
            verificationCode: String
        ) async throws {
            // Method signature test
        }

        func sendEmailVerificationConfirmation(
            to email: String,
            user: any User
        ) async throws {
            // Method signature test
        }

        func sendPasswordResetEmail(
            to email: String,
            user: any User,
            passwordResetURL: URL,
            passwordResetCode: String
        ) async throws {
            // Method signature test
        }

        func sendWelcomeEmail(
            to email: String,
            user: any User
        ) async throws {
            // Method signature test
        }

        func sendMagicLinkEmail(
            to email: String,
            user: (any User)?,
            magicLinkURL: URL
        ) async throws {
            // Method signature test
        }
    }

    @Test("EmailDelivery protocol can be implemented")
    func emailDeliveryProtocolImplementation() {
        let delivery: any Passage.EmailDelivery = MockEmailDelivery()
        #expect(delivery is MockEmailDelivery)
    }

    @Test("EmailDelivery protocol conforms to Sendable")
    func emailDeliveryProtocolIsSendable() {
        let delivery: any Sendable = MockEmailDelivery()
        #expect(delivery is MockEmailDelivery)
    }

    @Test("EmailDelivery has all required methods")
    func emailDeliveryRequiredMethods() async throws {
        let delivery = MockEmailDelivery()
        let user = MockUser(
            id: UUID(),
            email: "test@example.com",
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )
        let url = URL(string: "https://example.com/verify")!

        // Verify all methods can be called
        try await delivery.sendEmailVerification(
            to: "test@example.com",
            user: user,
            verificationURL: url,
            verificationCode: "123456"
        )

        try await delivery.sendEmailVerificationConfirmation(
            to: "test@example.com",
            user: user
        )

        try await delivery.sendPasswordResetEmail(
            to: "test@example.com",
            user: user,
            passwordResetURL: url,
            passwordResetCode: "123456"
        )

        try await delivery.sendWelcomeEmail(
            to: "test@example.com",
            user: user
        )
    }

    // MARK: - PhoneDelivery Protocol Tests

    struct MockPhoneDelivery: Passage.PhoneDelivery {
        var sentMessages: [String] = []

        func sendPhoneVerification(
            to phone: String,
            code: String,
            user: any User
        ) async throws {
            // Method signature test
        }

        func sendVerificationConfirmation(
            to phone: String,
            user: any User
        ) async throws {
            // Method signature test
        }

        func sendPasswordResetSMS(
            to phone: String,
            code: String,
            user: any User
        ) async throws {
            // Method signature test
        }
    }

    @Test("PhoneDelivery protocol can be implemented")
    func phoneDeliveryProtocolImplementation() {
        let delivery: any Passage.PhoneDelivery = MockPhoneDelivery()
        #expect(delivery is MockPhoneDelivery)
    }

    @Test("PhoneDelivery protocol conforms to Sendable")
    func phoneDeliveryProtocolIsSendable() {
        let delivery: any Sendable = MockPhoneDelivery()
        #expect(delivery is MockPhoneDelivery)
    }

    @Test("PhoneDelivery has all required methods")
    func phoneDeliveryRequiredMethods() async throws {
        let delivery = MockPhoneDelivery()
        let user = MockUser(
            id: UUID(),
            email: nil,
            phone: "+1234567890",
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )

        // Verify all methods can be called
        try await delivery.sendPhoneVerification(
            to: "+1234567890",
            code: "123456",
            user: user
        )

        try await delivery.sendVerificationConfirmation(
            to: "+1234567890",
            user: user
        )

        try await delivery.sendPasswordResetSMS(
            to: "+1234567890",
            code: "123456",
            user: user
        )
    }

    // MARK: - FederatedLoginService Protocol Tests

    struct MockFederatedLoginService: Passage.FederatedLoginService {
        func register(
            router: any RoutesBuilder,
            origin: URL,
            group: [PathComponent],
            config: Passage.Configuration.FederatedLogin,
            completion: @escaping @Sendable (
                _ provider: Passage.FederatedLogin.Provider,
                _ request: Request,
                _ payload: String
            ) async throws -> some AsyncResponseEncodable
        ) throws {
            // Method signature test
        }
    }

    @Test("FederatedLoginService protocol can be implemented")
    func federatedLoginServiceProtocolImplementation() {
        let service: any Passage.FederatedLoginService = MockFederatedLoginService()
        #expect(service is MockFederatedLoginService)
    }

    @Test("FederatedLoginService protocol conforms to Sendable")
    func federatedLoginServiceProtocolIsSendable() {
        let service: any Sendable = MockFederatedLoginService()
        #expect(service is MockFederatedLoginService)
    }

    // MARK: - Protocol Integration Tests

    @Test("Multiple delivery protocols can coexist")
    func multipleDeliveryProtocolsCoexist() {
        let emailDelivery: any Passage.EmailDelivery = MockEmailDelivery()
        let phoneDelivery: any Passage.PhoneDelivery = MockPhoneDelivery()

        #expect(emailDelivery is MockEmailDelivery)
        #expect(phoneDelivery is MockPhoneDelivery)
    }

    @Test("Delivery protocols are independent")
    func deliveryProtocolsIndependent() {
        let emailDelivery = MockEmailDelivery()
        let phoneDelivery = MockPhoneDelivery()

        // Both can be used independently
        #expect(emailDelivery is MockEmailDelivery)
        #expect(phoneDelivery is MockPhoneDelivery)
        #expect(!(emailDelivery is MockPhoneDelivery))
        #expect(!(phoneDelivery is MockEmailDelivery))
    }

    // MARK: - Custom Implementation Tests

    actor CustomEmailDelivery: Passage.EmailDelivery {
        var emailsSent: Int = 0

        func sendEmailVerification(
            to email: String,
            user: any User,
            verificationURL: URL,
            verificationCode: String
        ) async throws {
            emailsSent += 1
        }

        func sendEmailVerificationConfirmation(
            to email: String,
            user: any User
        ) async throws {
            emailsSent += 1
        }

        func sendPasswordResetEmail(
            to email: String,
            user: any User,
            passwordResetURL: URL,
            passwordResetCode: String
        ) async throws {
            emailsSent += 1
        }

        func sendWelcomeEmail(
            to email: String,
            user: any User
        ) async throws {
            emailsSent += 1
        }

        func sendMagicLinkEmail(
            to email: String,
            user: (any User)?,
            magicLinkURL: URL
        ) async throws {
            emailsSent += 1
        }
    }

    @Test("Custom actor-based EmailDelivery implementation")
    func customActorEmailDelivery() async throws {
        let delivery = CustomEmailDelivery()
        let user = MockUser(
            id: UUID(),
            email: "test@example.com",
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )
        let url = URL(string: "https://example.com")!

        try await delivery.sendEmailVerification(
            to: "test@example.com",
            user: user,
            verificationURL: url,
            verificationCode: "123456"
        )

        let count = await delivery.emailsSent
        #expect(count == 1)
    }

    // MARK: - Error Handling Tests

    struct FailingEmailDelivery: Passage.EmailDelivery {
        struct DeliveryError: Error {}

        func sendEmailVerification(
            to email: String,
            user: any User,
            verificationURL: URL,
            verificationCode: String
        ) async throws {
            throw DeliveryError()
        }

        func sendEmailVerificationConfirmation(
            to email: String,
            user: any User
        ) async throws {
            throw DeliveryError()
        }

        func sendPasswordResetEmail(
            to email: String,
            user: any User,
            passwordResetURL: URL,
            passwordResetCode: String
        ) async throws {
            throw DeliveryError()
        }

        func sendWelcomeEmail(
            to email: String,
            user: any User
        ) async throws {
            throw DeliveryError()
        }

        func sendMagicLinkEmail(
            to email: String,
            user: (any User)?,
            magicLinkURL: URL
        ) async throws {
            throw DeliveryError()
        }
    }

    @Test("EmailDelivery can throw errors")
    func emailDeliveryCanThrowErrors() async {
        let delivery = FailingEmailDelivery()
        let user = MockUser(
            id: UUID(),
            email: "test@example.com",
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )
        let url = URL(string: "https://example.com")!

        await #expect(throws: FailingEmailDelivery.DeliveryError.self) {
            try await delivery.sendEmailVerification(
                to: "test@example.com",
                user: user,
                verificationURL: url,
                verificationCode: "123456"
            )
        }
    }
}
