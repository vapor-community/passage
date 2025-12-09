import Testing
import Foundation
@testable import Passage

@Suite("VerificationCode Protocol Tests")
struct VerificationCodeProtocolTests {

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

        var sessionID: String {
            guard let id = id else {
                fatalError("MockUser must have an ID for session authentication")
            }
            return id.uuidString
        }
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

    // MARK: - isExpired Tests

    @Test("VerificationCode isExpired returns true when expired")
    func isExpiredWhenExpired() {
        let code = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: "test@example.com",
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date().addingTimeInterval(-60), // expired 1 minute ago
            failedAttempts: 0,
            email: "test@example.com"
        )

        #expect(code.isExpired == true)
    }

    @Test("VerificationCode isExpired returns false when not expired")
    func isExpiredWhenNotExpired() {
        let code = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: "test@example.com",
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date().addingTimeInterval(900), // expires in 15 minutes
            failedAttempts: 0,
            email: "test@example.com"
        )

        #expect(code.isExpired == false)
    }

    // MARK: - isValid Tests

    @Test("VerificationCode isValid returns true when not expired and under max attempts")
    func isValidWhenValid() {
        let code = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: "test@example.com",
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date().addingTimeInterval(900),
            failedAttempts: 1,
            email: "test@example.com"
        )

        #expect(code.isValid(maxAttempts: 3) == true)
    }

    @Test("VerificationCode isValid returns false when expired")
    func isValidWhenExpired() {
        let code = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: "test@example.com",
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date().addingTimeInterval(-60),
            failedAttempts: 0,
            email: "test@example.com"
        )

        #expect(code.isValid(maxAttempts: 3) == false)
    }

    @Test("VerificationCode isValid returns false when max attempts reached")
    func isValidWhenMaxAttemptsReached() {
        let code = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: "test@example.com",
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date().addingTimeInterval(900),
            failedAttempts: 3,
            email: "test@example.com"
        )

        #expect(code.isValid(maxAttempts: 3) == false)
    }

    @Test("VerificationCode isValid at boundary of max attempts")
    func isValidAtBoundary() {
        let code = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: "test@example.com",
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date().addingTimeInterval(900),
            failedAttempts: 2,
            email: "test@example.com"
        )

        #expect(code.isValid(maxAttempts: 3) == true)
        #expect(code.isValid(maxAttempts: 2) == false)
    }

    // MARK: - EmailVerificationCode Tests

    @Test("EmailVerificationCode stores email correctly")
    func emailVerificationCodeEmail() {
        let email = "test@example.com"
        let code = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: email,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date(),
            failedAttempts: 0,
            email: email
        )

        #expect(code.email == email)
    }

    @Test("EmailVerificationCode conforms to VerificationCode")
    func emailVerificationCodeConformance() {
        let code: any VerificationCode = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: "test@example.com",
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date(),
            failedAttempts: 0,
            email: "test@example.com"
        )

        #expect(code is MockEmailVerificationCode)
    }

    // MARK: - PhoneVerificationCode Tests

    @Test("PhoneVerificationCode stores phone correctly")
    func phoneVerificationCodePhone() {
        let phone = "+1234567890"
        let code = MockPhoneVerificationCode(
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: phone,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date(),
            failedAttempts: 0,
            phone: phone
        )

        #expect(code.phone == phone)
    }

    @Test("PhoneVerificationCode conforms to VerificationCode")
    func phoneVerificationCodeConformance() {
        let code: any VerificationCode = MockPhoneVerificationCode(
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: "+1234567890",
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date(),
            failedAttempts: 0,
            phone: "+1234567890"
        )

        #expect(code is MockPhoneVerificationCode)
    }

    // MARK: - Protocol Conformance Tests

    @Test("VerificationCode protocol conforms to Sendable")
    func verificationCodeProtocolIsSendable() {
        let code: any Sendable = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: "test@example.com",
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date(),
            failedAttempts: 0,
            email: "test@example.com"
        )
        #expect(code is MockEmailVerificationCode)
    }

    // MARK: - Properties Tests

    @Test("VerificationCode stores codeHash correctly")
    func codeHashStorage() {
        let hash = "abc123hash"
        let code = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: "test@example.com",
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: hash,
            expiresAt: Date(),
            failedAttempts: 0,
            email: "test@example.com"
        )

        #expect(code.codeHash == hash)
    }

    @Test("VerificationCode tracks failed attempts")
    func failedAttemptsTracking() {
        let code = MockEmailVerificationCode(
            user: MockUser(
                id: UUID(),
                email: "test@example.com",
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            codeHash: "hash",
            expiresAt: Date(),
            failedAttempts: 2,
            email: "test@example.com"
        )

        #expect(code.failedAttempts == 2)
    }

    @Test("VerificationCode stores user reference")
    func userReference() {
        let userId = UUID()
        let user = MockUser(
            id: userId,
            email: "test@example.com",
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )
        let code = MockEmailVerificationCode(
            user: user,
            codeHash: "hash",
            expiresAt: Date(),
            failedAttempts: 0,
            email: "test@example.com"
        )

        #expect(code.user.id == userId)
        #expect(code.user.email == "test@example.com")
    }
}
