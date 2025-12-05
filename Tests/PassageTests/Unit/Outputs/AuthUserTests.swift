import Testing
import Vapor
@testable import Passage

@Suite("AuthUser Tests")
struct AuthUserTests {

    // MARK: - AuthUser Initialization Tests

    @Test("AuthUser initialization with all properties")
    func authUserInitialization() {
        let user = AuthUser.User(
            id: "user123",
            email: "test@example.com",
            phone: "+1234567890"
        )

        let authUser = AuthUser(
            accessToken: "access_token_here",
            refreshToken: "refresh_token_here",
            tokenType: "Bearer",
            expiresIn: 3600,
            user: user
        )

        #expect(authUser.accessToken == "access_token_here")
        #expect(authUser.refreshToken == "refresh_token_here")
        #expect(authUser.tokenType == "Bearer")
        #expect(authUser.expiresIn == 3600)
        #expect(authUser.user.id == "user123")
        #expect(authUser.user.email == "test@example.com")
        #expect(authUser.user.phone == "+1234567890")
    }

    @Test("AuthUser with nil email and phone")
    func authUserWithNilEmailAndPhone() {
        let user = AuthUser.User(
            id: "user123",
            email: nil,
            phone: nil
        )

        let authUser = AuthUser(
            accessToken: "access_token",
            refreshToken: "refresh_token",
            tokenType: "Bearer",
            expiresIn: 3600,
            user: user
        )

        #expect(authUser.user.email == nil)
        #expect(authUser.user.phone == nil)
    }

    // MARK: - AuthUser.User Tests

    @Test("AuthUser.User initialization")
    func authUserUserInitialization() {
        let user = AuthUser.User(
            id: "user_id_123",
            email: "john@example.com",
            phone: "+19876543210"
        )

        #expect(user.id == "user_id_123")
        #expect(user.email == "john@example.com")
        #expect(user.phone == "+19876543210")
    }

    @Test("AuthUser.User with only email")
    func authUserUserWithOnlyEmail() {
        let user = AuthUser.User(
            id: "user123",
            email: "test@example.com",
            phone: nil
        )

        #expect(user.email == "test@example.com")
        #expect(user.phone == nil)
    }

    @Test("AuthUser.User with only phone")
    func authUserUserWithOnlyPhone() {
        let user = AuthUser.User(
            id: "user123",
            email: nil,
            phone: "+1234567890"
        )

        #expect(user.email == nil)
        #expect(user.phone == "+1234567890")
    }

    // MARK: - Protocol Conformance Tests

    @Test("AuthUser conforms to Content")
    func authUserConformsToContent() {
        let user = AuthUser.User(id: "user123", email: "test@example.com", phone: nil)
        let authUser = AuthUser(
            accessToken: "token",
            refreshToken: "refresh",
            tokenType: "Bearer",
            expiresIn: 3600,
            user: user
        )

        let _: any Content = authUser
        #expect(authUser is Content)
    }

    @Test("AuthUser.User conforms to Content")
    func authUserUserConformsToContent() {
        let user = AuthUser.User(id: "user123", email: "test@example.com", phone: nil)
        let _: any Content = user
        #expect(user is Content)
    }

    @Test("AuthUser.User conforms to UserInfo")
    func authUserUserConformsToUserInfo() {
        let user = AuthUser.User(id: "user123", email: "test@example.com", phone: "+1234567890")
        let _: any UserInfo = user
        #expect(user is UserInfo)
    }

    // MARK: - Token Type Tests

    @Test("AuthUser with Bearer token type")
    func authUserWithBearerTokenType() {
        let user = AuthUser.User(id: "user123", email: "test@example.com", phone: nil)
        let authUser = AuthUser(
            accessToken: "token",
            refreshToken: "refresh",
            tokenType: "Bearer",
            expiresIn: 3600,
            user: user
        )

        #expect(authUser.tokenType == "Bearer")
    }

    @Test("AuthUser with custom token type")
    func authUserWithCustomTokenType() {
        let user = AuthUser.User(id: "user123", email: "test@example.com", phone: nil)
        let authUser = AuthUser(
            accessToken: "token",
            refreshToken: "refresh",
            tokenType: "Custom",
            expiresIn: 3600,
            user: user
        )

        #expect(authUser.tokenType == "Custom")
    }

    // MARK: - ExpiresIn Tests

    @Test("AuthUser with different expiresIn values", arguments: [
        300.0,    // 5 minutes
        3600.0,   // 1 hour
        7200.0,   // 2 hours
        86400.0   // 1 day
    ])
    func authUserWithDifferentExpiresIn(expiresIn: TimeInterval) {
        let user = AuthUser.User(id: "user123", email: "test@example.com", phone: nil)
        let authUser = AuthUser(
            accessToken: "token",
            refreshToken: "refresh",
            tokenType: "Bearer",
            expiresIn: expiresIn,
            user: user
        )

        #expect(authUser.expiresIn == expiresIn)
    }

    // MARK: - Token Properties Tests

    @Test("AuthUser stores accessToken correctly")
    func authUserStoresAccessToken() {
        let user = AuthUser.User(id: "user123", email: "test@example.com", phone: nil)
        let authUser = AuthUser(
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
            refreshToken: "refresh_token_value",
            tokenType: "Bearer",
            expiresIn: 3600,
            user: user
        )

        #expect(authUser.accessToken == "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
    }

    @Test("AuthUser stores refreshToken correctly")
    func authUserStoresRefreshToken() {
        let user = AuthUser.User(id: "user123", email: "test@example.com", phone: nil)
        let authUser = AuthUser(
            accessToken: "access_token_value",
            refreshToken: "opaque_refresh_token_12345",
            tokenType: "Bearer",
            expiresIn: 3600,
            user: user
        )

        #expect(authUser.refreshToken == "opaque_refresh_token_12345")
    }

    // MARK: - Nested User Structure Tests

    @Test("AuthUser.User as nested struct")
    func authUserUserAsNestedStruct() {
        // Verify that User is properly nested within AuthUser
        let typeName = String(reflecting: AuthUser.User.self)
        #expect(typeName.contains("AuthUser.User"))
    }

    // MARK: - Multiple AuthUser Instances Tests

    @Test("Multiple AuthUser instances are independent")
    func multipleAuthUserInstancesIndependent() {
        let user1 = AuthUser.User(id: "user1", email: "user1@example.com", phone: nil)
        let authUser1 = AuthUser(
            accessToken: "token1",
            refreshToken: "refresh1",
            tokenType: "Bearer",
            expiresIn: 3600,
            user: user1
        )

        let user2 = AuthUser.User(id: "user2", email: "user2@example.com", phone: nil)
        let authUser2 = AuthUser(
            accessToken: "token2",
            refreshToken: "refresh2",
            tokenType: "Bearer",
            expiresIn: 7200,
            user: user2
        )

        #expect(authUser1.user.id == "user1")
        #expect(authUser2.user.id == "user2")
        #expect(authUser1.accessToken != authUser2.accessToken)
        #expect(authUser1.expiresIn != authUser2.expiresIn)
    }

    // MARK: - UserInfo Protocol Implementation Tests

    @Test("AuthUser.User email property from UserInfo")
    func authUserUserEmailFromUserInfo() {
        let user: any UserInfo = AuthUser.User(
            id: "user123",
            email: "test@example.com",
            phone: "+1234567890"
        )

        #expect(user.email == "test@example.com")
        #expect(user.phone == "+1234567890")
    }
}
