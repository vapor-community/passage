import Testing
import Foundation
@testable import Passage

@Suite("RestorationCode Protocol Tests")
struct RestorationCodeProtocolTests {

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

    // MARK: - isExpired Tests

    @Test("RestorationCode isExpired returns true when expired")
    func isExpiredWhenExpired() {
        let code = MockEmailPasswordResetCode(
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

    @Test("RestorationCode isExpired returns false when not expired")
    func isExpiredWhenNotExpired() {
        let code = MockEmailPasswordResetCode(
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

    @Test("RestorationCode isValid returns true when not expired and under max attempts")
    func isValidWhenValid() {
        let code = MockEmailPasswordResetCode(
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

    @Test("RestorationCode isValid returns false when expired")
    func isValidWhenExpired() {
        let code = MockEmailPasswordResetCode(
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

    @Test("RestorationCode isValid returns false when max attempts reached")
    func isValidWhenMaxAttemptsReached() {
        let code = MockEmailPasswordResetCode(
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

    @Test("RestorationCode isValid at boundary of max attempts")
    func isValidAtBoundary() {
        let code = MockEmailPasswordResetCode(
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

    // MARK: - EmailPasswordResetCode Tests

    @Test("EmailPasswordResetCode stores email correctly")
    func emailPasswordResetCodeEmail() {
        let email = "test@example.com"
        let code = MockEmailPasswordResetCode(
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

    @Test("EmailPasswordResetCode conforms to RestorationCode")
    func emailPasswordResetCodeConformance() {
        let code: any RestorationCode = MockEmailPasswordResetCode(
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

        #expect(code is MockEmailPasswordResetCode)
    }

    // MARK: - PhonePasswordResetCode Tests

    @Test("PhonePasswordResetCode stores phone correctly")
    func phonePasswordResetCodePhone() {
        let phone = "+1234567890"
        let code = MockPhonePasswordResetCode(
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

    @Test("PhonePasswordResetCode conforms to RestorationCode")
    func phonePasswordResetCodeConformance() {
        let code: any RestorationCode = MockPhonePasswordResetCode(
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

        #expect(code is MockPhonePasswordResetCode)
    }

    // MARK: - Protocol Conformance Tests

    @Test("RestorationCode protocol conforms to Sendable")
    func restorationCodeProtocolIsSendable() {
        let code: any Sendable = MockEmailPasswordResetCode(
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
        #expect(code is MockEmailPasswordResetCode)
    }

    // MARK: - Properties Tests

    @Test("RestorationCode stores codeHash correctly")
    func codeHashStorage() {
        let hash = "abc123hash"
        let code = MockEmailPasswordResetCode(
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

    @Test("RestorationCode tracks failed attempts")
    func failedAttemptsTracking() {
        let code = MockEmailPasswordResetCode(
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

    @Test("RestorationCode stores user reference")
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
        let code = MockEmailPasswordResetCode(
            user: user,
            codeHash: "hash",
            expiresAt: Date(),
            failedAttempts: 0,
            email: "test@example.com"
        )

        #expect(code.user.id == userId)
        #expect(code.user.email == "test@example.com")
    }

    // MARK: - Different Max Attempts Tests

    @Test("RestorationCode isValid with different max attempts", arguments: [
        (0, 1, true),
        (1, 1, false),
        (2, 3, true),
        (3, 3, false),
        (5, 10, true)
    ])
    func isValidWithDifferentMaxAttempts(failedAttempts: Int, maxAttempts: Int, expectedValid: Bool) {
        let code = MockEmailPasswordResetCode(
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
            failedAttempts: failedAttempts,
            email: "test@example.com"
        )

        #expect(code.isValid(maxAttempts: maxAttempts) == expectedValid)
    }
}
