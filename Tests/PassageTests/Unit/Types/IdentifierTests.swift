import Testing
@testable import Passage

@Suite("Identifier Tests")
struct IdentifierTests {

    // MARK: - Initialization Tests

    @Test("Email identifier initialization")
    func emailIdentifierInitialization() {
        let identifier = Identifier(kind: .email, value: "test@example.com", provider: nil)

        #expect(identifier.kind == Identifier.Kind.email)
        #expect(identifier.value == "test@example.com")
        #expect(identifier.provider == nil)
    }

    @Test("Phone identifier initialization")
    func phoneIdentifierInitialization() {
        let identifier = Identifier(kind: .phone, value: "+1234567890", provider: nil)

        #expect(identifier.kind == Identifier.Kind.phone)
        #expect(identifier.value == "+1234567890")
        #expect(identifier.provider == nil)
    }

    @Test("Username identifier initialization")
    func usernameIdentifierInitialization() {
        let identifier = Identifier(kind: .username, value: "johndoe", provider: nil)

        #expect(identifier.kind == Identifier.Kind.username)
        #expect(identifier.value == "johndoe")
        #expect(identifier.provider == nil)
    }

    @Test("Federated identifier initialization")
    func federatedIdentifierInitialization() {
        let identifier = Identifier(kind: .federated, value: "oauth-user-123", provider: "google")

        #expect(identifier.kind == Identifier.Kind.federated)
        #expect(identifier.value == "oauth-user-123")
        #expect(identifier.provider == "google")
    }

    // MARK: - Convenience Initializer Tests

    @Test("Email convenience initializer")
    func emailConvenienceInitializer() {
        let identifier = Identifier.email("test@example.com")

        #expect(identifier.kind == Identifier.Kind.email)
        #expect(identifier.value == "test@example.com")
        #expect(identifier.provider == nil)
    }

    @Test("Phone convenience initializer")
    func phoneConvenienceInitializer() {
        let identifier = Identifier.phone("+1234567890")

        #expect(identifier.kind == Identifier.Kind.phone)
        #expect(identifier.value == "+1234567890")
        #expect(identifier.provider == nil)
    }

    @Test("Username convenience initializer")
    func usernameConvenienceInitializer() {
        let identifier = Identifier.username("johndoe")

        #expect(identifier.kind == Identifier.Kind.username)
        #expect(identifier.value == "johndoe")
        #expect(identifier.provider == nil)
    }

    @Test("Federated convenience initializer")
    func federatedConvenienceInitializer() {
        let identifier = Identifier.federated("github", userId: "12345")

        #expect(identifier.kind == Identifier.Kind.federated)
        #expect(identifier.value == "12345")
        #expect(identifier.provider == "github")
    }

    // MARK: - Error Support Tests

    @Test("Identifier error when already registered", arguments: [
        (Identifier.Kind.email, AuthenticationError.emailAlreadyRegistered),
        (Identifier.Kind.phone, AuthenticationError.phoneAlreadyRegistered),
        (Identifier.Kind.username, AuthenticationError.usernameAlreadyRegistered),
        (Identifier.Kind.federated, AuthenticationError.federatedAccountAlreadyLinked)
    ])
    func errorWhenAlreadyRegistered(kind: Identifier.Kind, expected: AuthenticationError) {
        let identifier = Identifier(kind: kind, value: "test-value", provider: kind == .federated ? "test-provider" : nil)
        #expect(identifier.errorWhenIdentifierAlreadyRegistered == expected)
    }

    @Test("Identifier error when invalid", arguments: [
        (Identifier.Kind.email, AuthenticationError.invalidEmailOrPassword),
        (Identifier.Kind.phone, AuthenticationError.invalidPhoneOrPassword),
        (Identifier.Kind.username, AuthenticationError.invalidUsernameOrPassword),
        (Identifier.Kind.federated, AuthenticationError.federatedLoginFailed)
    ])
    func errorWhenInvalid(kind: Identifier.Kind, expected: AuthenticationError) {
        let identifier = Identifier(kind: kind, value: "test-value", provider: kind == .federated ? "test-provider" : nil)
        #expect(identifier.errorWhenIdentifierIsInvalid == expected)
    }

    // MARK: - Kind Enum Tests

    @Test("Identifier kind raw values", arguments: [
        (Identifier.Kind.email, "email"),
        (Identifier.Kind.phone, "phone"),
        (Identifier.Kind.username, "username"),
        (Identifier.Kind.federated, "federated")
    ])
    func kindRawValues(kind: Identifier.Kind, expectedRawValue: String) {
        #expect(kind.rawValue == expectedRawValue)
    }

    @Test("Identifier kind from raw value", arguments: [
        ("email", Identifier.Kind.email),
        ("phone", Identifier.Kind.phone),
        ("username", Identifier.Kind.username),
        ("federated", Identifier.Kind.federated)
    ])
    func kindFromRawValue(rawValue: String, expected: Identifier.Kind?) {
        #expect(Identifier.Kind(rawValue: rawValue) == expected)
    }

    @Test("Identifier kind from invalid raw value")
    func kindFromInvalidRawValue() {
        #expect(Identifier.Kind(rawValue: "invalid") == nil)
    }
}
