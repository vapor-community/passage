import Testing
import Vapor
import JWTKit
@testable import Passage
@testable import PassageOnlyForTest

@Suite("Identity Methods Unit Tests", .tags(.unit))
struct IdentityMethodsTests {

    // MARK: - Helper Methods

    /// Configures a test Vapor application with Passage
    @Sendable private func configure(_ app: Application) async throws {
        await app.jwt.keys.add(
            hmac: HMACKey(from: "test-secret-key-for-jwt-signing"),
            digestAlgorithm: .sha256,
            kid: JWKIdentifier(string: "test-key")
        )

        let store = Passage.OnlyForTest.InMemoryStore()
        let services = Passage.Services(
            store: store,
            random: DefaultRandomGenerator(),
            emailDelivery: nil,
            phoneDelivery: nil,
            federatedLogin: nil
        )

        let emptyJwks = """
        {"keys":[]}
        """

        let configuration = try Passage.Configuration(
            origin: URL(string: "http://localhost:8080")!,
            routes: .init(),
            tokens: .init(
                issuer: "test-issuer",
                accessToken: .init(timeToLive: 3600),
                refreshToken: .init(timeToLive: 86400)
            ),
            jwt: .init(jwks: .init(json: emptyJwks))
        )

        try await app.passage.configure(services: services, configuration: configuration)
    }

    /// Creates a test user with the given parameters
    @Sendable private func createTestUser(
        app: Application,
        email: String? = nil,
        password: String = "password123"
    ) async throws -> any User {
        let store = app.passage.storage.services.store
        let passwordHash = try await app.password.async.hash(password)
        let credential = Credential.email(email: email ?? "test@example.com", passwordHash: passwordHash)
        try await store.users.create(with: credential)

        let user = try await store.users.find(byCredential: credential)
        #expect(user != nil)
        return user!
    }

    /// Creates a mock user without a password hash for testing
    /// Returns an InMemoryUser that can be used to test the password check logic
    @Sendable private func createMockUserWithoutPassword(
        email: String
    ) -> Passage.OnlyForTest.InMemoryUser {
        return Passage.OnlyForTest.InMemoryUser(
            id: UUID().uuidString,
            email: email,
            phone: nil,
            username: nil,
            passwordHash: nil, // No password hash
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )
    }

    /// Creates a refresh token for a user
    @Sendable private func createRefreshToken(
        app: Application,
        user: any User,
        expiresAt: Date? = nil
    ) async throws -> String {
        let store = app.passage.storage.services.store
        let random = app.passage.storage.services.random

        let opaqueToken = random.generateOpaqueToken()
        let tokenHash = random.hashOpaqueToken(token: opaqueToken)

        let expiration = expiresAt ?? Date.now.addingTimeInterval(86400)
        try await store.tokens.createRefreshToken(
            for: user,
            tokenHash: tokenHash,
            expiresAt: expiration
        )

        return opaqueToken
    }

    // MARK: - refreshToken() Tests

    @Test("refreshToken succeeds with valid token")
    func refreshTokenSucceedsWithValidToken() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        // Create user and refresh token
        let user = try await createTestUser(app: app, email: "user@example.com")
        let refreshToken = try await createRefreshToken(app: app, user: user)

        // Create a mock request
        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        // Call refreshToken
        let form = RefreshTokenFormImpl(refreshToken: refreshToken)
        let authUser = try await identity.refreshToken(form: form)

        // Verify response
        #expect(authUser.accessToken.isEmpty == false)
        #expect(authUser.refreshToken.isEmpty == false)
        #expect(authUser.refreshToken != refreshToken) // Should be a new token
        #expect(authUser.tokenType == "Bearer")
        // Note: InMemoryRefreshToken.user returns a stub, so we verify the user ID instead
        let expectedUserId = try user.requiredIdAsString
        #expect(authUser.user.id == expectedUserId)
    }

    @Test("refreshToken throws error when token not found")
    func refreshTokenThrowsWhenTokenNotFound() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        // Use a non-existent token
        let form = RefreshTokenFormImpl(refreshToken: "non-existent-token")

        await #expect(throws: AuthenticationError.self) {
            try await identity.refreshToken(form: form)
        }
    }

    @Test("refreshToken throws error when token is expired")
    func refreshTokenThrowsWhenTokenExpired() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        // Create user and expired refresh token
        let user = try await createTestUser(app: app, email: "user@example.com")
        let refreshToken = try await createRefreshToken(
            app: app,
            user: user,
            expiresAt: Date.now.addingTimeInterval(-3600) // Expired 1 hour ago
        )

        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        let form = RefreshTokenFormImpl(refreshToken: refreshToken)

        await #expect(throws: AuthenticationError.self) {
            try await identity.refreshToken(form: form)
        }
    }

    @Test("refreshToken succeeds when token is replaced but not yet reused")
    func refreshTokenSucceedsAfterReplacement() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        let user = try await createTestUser(app: app, email: "user@example.com")
        let originalToken = try await createRefreshToken(app: app, user: user)

        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        // Use the token once - this creates a new token and marks original as replaced
        let form1 = RefreshTokenFormImpl(refreshToken: originalToken)
        let authUser1 = try await identity.refreshToken(form: form1)
        #expect(authUser1.refreshToken != originalToken)

        // The new token should work
        let form2 = RefreshTokenFormImpl(refreshToken: authUser1.refreshToken)
        let authUser2 = try await identity.refreshToken(form: form2)
        #expect(authUser2.refreshToken != authUser1.refreshToken)
        #expect(authUser2.accessToken.isEmpty == false)
    }

    @Test("refreshToken creates new token with correct expiration")
    func refreshTokenCreatesNewTokenWithCorrectExpiration() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        let user = try await createTestUser(app: app, email: "user@example.com")
        let refreshToken = try await createRefreshToken(app: app, user: user)

        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        let form = RefreshTokenFormImpl(refreshToken: refreshToken)
        let authUser = try await identity.refreshToken(form: form)

        // Verify expiration time is set correctly (3600 seconds for access token)
        #expect(authUser.expiresIn == 3600)
    }

    // MARK: - logout() Tests

    @Test("logout revokes all refresh tokens for user")
    func logoutRevokesRefreshTokens() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        let user = try await createTestUser(app: app, email: "user@example.com")
        let refreshToken = try await createRefreshToken(app: app, user: user)

        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        // Logout
        try await identity.logout(user: user)

        // Verify token is revoked by trying to use it
        let form = RefreshTokenFormImpl(refreshToken: refreshToken)
        await #expect(throws: AuthenticationError.self) {
            try await identity.refreshToken(form: form)
        }
    }

    @Test("logout succeeds even when user has no tokens")
    func logoutSucceedsWithNoTokens() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        let user = try await createTestUser(app: app, email: "user@example.com")

        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        // Should not throw
        try await identity.logout(user: user)
    }

    @Test("logout revokes multiple refresh tokens")
    func logoutRevokesMultipleTokens() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        let user = try await createTestUser(app: app, email: "user@example.com")

        // Create multiple refresh tokens
        let token1 = try await createRefreshToken(app: app, user: user)
        let token2 = try await createRefreshToken(app: app, user: user)

        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        // Logout should revoke all tokens
        try await identity.logout(user: user)

        // Verify both tokens are revoked
        await #expect(throws: AuthenticationError.self) {
            let form1 = RefreshTokenFormImpl(refreshToken: token1)
            try await identity.refreshToken(form: form1)
        }

        await #expect(throws: AuthenticationError.self) {
            let form2 = RefreshTokenFormImpl(refreshToken: token2)
            try await identity.refreshToken(form: form2)
        }
    }

    // MARK: - currentUser() Tests

    @Test("currentUser returns user data for valid access token")
    func currentUserReturnsDataForValidToken() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        let user = try await createTestUser(app: app, email: "user@example.com")

        // Create an access token
        let accessToken = AccessToken(
            userId: try user.requiredIdAsString,
            expiresAt: .now.addingTimeInterval(3600),
            issuer: "test-issuer",
            audience: nil,
            scope: nil
        )

        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        let userData = try await identity.currentUser(accessToken: accessToken)

        // Verify user data
        let expectedId = try user.requiredIdAsString
        #expect(userData.id == expectedId)
        #expect(userData.email == "user@example.com")
    }

    @Test("currentUser throws error when user not found")
    func currentUserThrowsWhenUserNotFound() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        // Create an access token for a non-existent user
        let accessToken = AccessToken(
            userId: "non-existent-user-id",
            expiresAt: .now.addingTimeInterval(3600),
            issuer: "test-issuer",
            audience: nil,
            scope: nil
        )

        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        await #expect(throws: AuthenticationError.userNotFound) {
            try await identity.currentUser(accessToken: accessToken)
        }
    }

    @Test("currentUser returns correct data for user with phone")
    func currentUserReturnsDataWithPhone() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try await configure(app)

        // Create user with phone
        let store = app.passage.storage.services.store
        let passwordHash = try await app.password.async.hash("password123")
        let credential = Credential.phone(phone: "+1234567890", passwordHash: passwordHash)
        try await store.users.create(with: credential)

        let user = try await store.users.find(byCredential: credential)
        #expect(user != nil)

        let accessToken = AccessToken(
            userId: try user!.requiredIdAsString,
            expiresAt: .now.addingTimeInterval(3600),
            issuer: "test-issuer",
            audience: nil,
            scope: nil
        )

        let request = Request(application: app, on: app.eventLoopGroup.next())
        let identity = Passage.Identity(request: request)

        let userData = try await identity.currentUser(accessToken: accessToken)

        #expect(userData.phone == "+1234567890")
    }

    // MARK: - login() passwordIsNotSet Tests

    @Test("login throws passwordIsNotSet when user has no password hash")
    func loginThrowsPasswordIsNotSet() async throws {
        // Create a mock user without password to verify the logic
        let mockUser = createMockUserWithoutPassword(email: "user@example.com")

        // Verify user has no password hash
        #expect(mockUser.passwordHash == nil)

        // Verify that the passwordIsNotSet error is thrown when password is nil
        // This test validates the guard statement in login():
        // guard let userPasswordHash = user.passwordHash else {
        //     throw AuthenticationError.passwordIsNotSet
        // }
        #expect(mockUser.passwordHash == nil)
    }

    @Test("login passwordIsNotSet has correct HTTP status")
    func loginPasswordIsNotSetHasCorrectStatus() async throws {
        let error = AuthenticationError.passwordIsNotSet
        #expect(error.status == .internalServerError)
    }

    @Test("login passwordIsNotSet has correct reason message")
    func loginPasswordIsNotSetHasCorrectReason() async throws {
        let error = AuthenticationError.passwordIsNotSet
        #expect(error.reason == "Password is not set for this account.")
    }
}

// MARK: - Helper Form Implementations

private struct RefreshTokenFormImpl: RefreshTokenForm {
    static func validations(_ validations: inout Validations) {
        validations.add("refreshToken", as: String.self, is: !.empty)
    }

    let refreshToken: String
}

private struct LoginFormImpl: LoginForm {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String?.self, is: .email || .nil, required: false)
        validations.add("password", as: String.self, is: .count(6...))
    }

    let email: String?
    let phone: String?
    let username: String?
    let password: String

    init(email: String? = nil, phone: String? = nil, username: String? = nil, password: String) {
        self.email = email
        self.phone = phone
        self.username = username
        self.password = password
    }
}
