import Testing
import Vapor
@testable import Passage

@Suite("User Protocol Tests")
struct UserProtocolTests {

    // MARK: - Mock User Implementation

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

    // MARK: - Protocol Extension Tests

    @Test("User requiredIdAsString returns string representation of ID")
    func requiredIdAsStringSuccess() throws {
        let userId = UUID()
        let user = MockUser(
            id: userId,
            email: nil,
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )

        let idString = try user.requiredIdAsString
        #expect(idString == userId.uuidString)
    }

    @Test("User requiredIdAsString throws when ID is nil")
    func requiredIdAsStringThrowsWhenNil() {
        let user = MockUser(
            id: nil,
            email: nil,
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )

        #expect(throws: PassageError.self) {
            _ = try user.requiredIdAsString
        }
    }

    // MARK: - Email Verification Check Tests

    @Test("User check succeeds for verified email")
    func checkVerifiedEmail() throws {
        let user = MockUser(
            id: UUID(),
            email: "test@example.com",
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: true,
            isPhoneVerified: false
        )

        let identifier = Identifier(kind: .email, value: "test@example.com")
        try user.check(identifier: identifier)
    }

    @Test("User check throws for unverified email")
    func checkUnverifiedEmail() {
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

        let identifier = Identifier(kind: .email, value: "test@example.com")
        #expect(throws: AuthenticationError.emailIsNotVerified) {
            try user.check(identifier: identifier)
        }
    }

    // MARK: - Phone Verification Check Tests

    @Test("User check succeeds for verified phone")
    func checkVerifiedPhone() throws {
        let user = MockUser(
            id: UUID(),
            email: nil,
            phone: "+1234567890",
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: true
        )

        let identifier = Identifier(kind: .phone, value: "+1234567890")
        try user.check(identifier: identifier)
    }

    @Test("User check throws for unverified phone")
    func checkUnverifiedPhone() {
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

        let identifier = Identifier(kind: .phone, value: "+1234567890")
        #expect(throws: AuthenticationError.phoneIsNotVerified) {
            try user.check(identifier: identifier)
        }
    }

    // MARK: - Username Check Tests

    @Test("User check succeeds for username without verification")
    func checkUsername() throws {
        let user = MockUser(
            id: UUID(),
            email: nil,
            phone: nil,
            username: "johndoe",
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )

        let identifier = Identifier(kind: .username, value: "johndoe")
        try user.check(identifier: identifier)
    }

    // MARK: - Protocol Conformance Tests

    @Test("MockUser conforms to User protocol")
    func mockUserConformsToProtocol() {
        let user: any User = MockUser(
            id: UUID(),
            email: nil,
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )
        #expect(user is MockUser)
    }

    @Test("User protocol conforms to Sendable")
    func userProtocolIsSendable() {
        let user: any Sendable = MockUser(
            id: UUID(),
            email: nil,
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )
        #expect(user is MockUser)
    }

    // MARK: - User Properties Tests

    @Test("User with all properties set")
    func userWithAllProperties() {
        let userId = UUID()
        let user = MockUser(
            id: userId,
            email: "test@example.com",
            phone: "+1234567890",
            username: "johndoe",
            passwordHash: "hashed_password",
            isAnonymous: false,
            isEmailVerified: true,
            isPhoneVerified: true
        )

        #expect(user.id == userId)
        #expect(user.email == "test@example.com")
        #expect(user.phone == "+1234567890")
        #expect(user.username == "johndoe")
        #expect(user.passwordHash == "hashed_password")
        #expect(user.isAnonymous == false)
        #expect(user.isEmailVerified == true)
        #expect(user.isPhoneVerified == true)
    }

    @Test("User with minimal properties")
    func userWithMinimalProperties() {
        let user = MockUser(
            id: nil,
            email: nil,
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: true,
            isEmailVerified: false,
            isPhoneVerified: false
        )

        #expect(user.id == nil)
        #expect(user.email == nil)
        #expect(user.phone == nil)
        #expect(user.username == nil)
        #expect(user.passwordHash == nil)
        #expect(user.isAnonymous == true)
        #expect(user.isEmailVerified == false)
        #expect(user.isPhoneVerified == false)
    }

    // MARK: - ID Type Tests

    @Test("User ID type is CustomStringConvertible")
    func userIdTypeIsCustomStringConvertible() {
        let userId = UUID()
        let user = MockUser(
            id: userId,
            email: nil,
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )

        let idDescription = user.id?.description
        #expect(idDescription != nil)
        #expect(idDescription == userId.uuidString)
    }
}
