import Testing
import Foundation
@testable import Passage

@Suite("RefreshToken Protocol Tests")
struct RefreshTokenProtocolTests {

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

    // MARK: - isExpired Tests

    @Test("RefreshToken isExpired returns true when expired")
    func isExpiredWhenExpired() {
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(-3600), // expired 1 hour ago
            revokedAt: nil,
            replacedBy: nil
        )

        #expect(token.isExpired == true)
    }

    @Test("RefreshToken isExpired returns false when not expired")
    func isExpiredWhenNotExpired() {
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(3600), // expires in 1 hour
            revokedAt: nil,
            replacedBy: nil
        )

        #expect(token.isExpired == false)
    }

    // MARK: - isRevoked Tests

    @Test("RefreshToken isRevoked returns true when revoked")
    func isRevokedWhenRevoked() {
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(3600),
            revokedAt: Date(),
            replacedBy: nil
        )

        #expect(token.isRevoked == true)
    }

    @Test("RefreshToken isRevoked returns false when not revoked")
    func isRevokedWhenNotRevoked() {
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(3600),
            revokedAt: nil,
            replacedBy: nil
        )

        #expect(token.isRevoked == false)
    }

    // MARK: - isValid Tests

    @Test("RefreshToken isValid returns true when not expired and not revoked")
    func isValidWhenValid() {
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(3600),
            revokedAt: nil,
            replacedBy: nil
        )

        #expect(token.isValid == true)
    }

    @Test("RefreshToken isValid returns false when expired")
    func isValidWhenExpired() {
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(-3600),
            revokedAt: nil,
            replacedBy: nil
        )

        #expect(token.isValid == false)
    }

    @Test("RefreshToken isValid returns false when revoked")
    func isValidWhenRevoked() {
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(3600),
            revokedAt: Date(),
            replacedBy: nil
        )

        #expect(token.isValid == false)
    }

    @Test("RefreshToken isValid returns false when both expired and revoked")
    func isValidWhenExpiredAndRevoked() {
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(-3600),
            revokedAt: Date(),
            replacedBy: nil
        )

        #expect(token.isValid == false)
    }

    // MARK: - Protocol Conformance Tests

    @Test("MockRefreshToken conforms to RefreshToken protocol")
    func mockRefreshTokenConformsToProtocol() {
        let token: any RefreshToken = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date(),
            revokedAt: nil,
            replacedBy: nil
        )
        #expect(token is MockRefreshToken)
    }

    @Test("RefreshToken protocol conforms to Sendable")
    func refreshTokenProtocolIsSendable() {
        let token: any Sendable = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date(),
            revokedAt: nil,
            replacedBy: nil
        )
        #expect(token is MockRefreshToken)
    }

    // MARK: - Token Rotation Tests

    @Test("RefreshToken with replacedBy set")
    func tokenWithReplacedBy() {
        let newTokenId = UUID()
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(3600),
            revokedAt: nil,
            replacedBy: newTokenId
        )

        #expect(token.replacedBy == newTokenId)
    }

    @Test("RefreshToken without replacedBy")
    func tokenWithoutReplacedBy() {
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(3600),
            revokedAt: nil,
            replacedBy: nil
        )

        #expect(token.replacedBy == nil)
    }

    // MARK: - Properties Tests

    @Test("RefreshToken stores tokenHash correctly")
    func tokenHashStorage() {
        let hash = "abc123hash456"
        let token = MockRefreshToken(
            id: UUID(),
            user: MockUser(
                id: UUID(),
                email: nil,
                phone: nil,
                username: nil,
                passwordHash: nil,
                isAnonymous: false,
                isEmailVerified: false,
                isPhoneVerified: false
            ),
            tokenHash: hash,
            expiresAt: Date(),
            revokedAt: nil,
            replacedBy: nil
        )

        #expect(token.tokenHash == hash)
    }

    @Test("RefreshToken stores user reference")
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
        let token = MockRefreshToken(
            id: UUID(),
            user: user,
            tokenHash: "hash",
            expiresAt: Date(),
            revokedAt: nil,
            replacedBy: nil
        )

        #expect(token.user.id == userId)
        #expect(token.user.email == "test@example.com")
    }
}
