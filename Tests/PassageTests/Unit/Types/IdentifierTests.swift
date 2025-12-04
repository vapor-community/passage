import Testing
@testable import Passage

@Suite("Identifier Tests")
struct IdentifierTests {

    // MARK: - Initialization Tests

    @Test("Email identifier initialization")
    func emailIdentifierInitialization() {
        let identifier = Identifier(kind: .email, value: "test@example.com")

        #expect(identifier.kind == .email)
        #expect(identifier.value == "test@example.com")
    }

    @Test("Phone identifier initialization")
    func phoneIdentifierInitialization() {
        let identifier = Identifier(kind: .phone, value: "+1234567890")

        #expect(identifier.kind == .phone)
        #expect(identifier.value == "+1234567890")
    }

    @Test("Username identifier initialization")
    func usernameIdentifierInitialization() {
        let identifier = Identifier(kind: .username, value: "johndoe")

        #expect(identifier.kind == .username)
        #expect(identifier.value == "johndoe")
    }

    // MARK: - Error Support Tests

    @Test("Identifier error when already registered", arguments: [
        (Identifier.Kind.email, AuthenticationError.emailAlreadyRegistered),
        (Identifier.Kind.phone, AuthenticationError.phoneAlreadyRegistered),
        (Identifier.Kind.username, AuthenticationError.usernameAlreadyRegistered)
    ])
    func errorWhenAlreadyRegistered(kind: Identifier.Kind, expected: AuthenticationError) {
        let identifier = Identifier(kind: kind, value: "test-value")
        #expect(identifier.errorWhenIdentifierAlreadyRegistered == expected)
    }

    @Test("Identifier error when invalid", arguments: [
        (Identifier.Kind.email, AuthenticationError.invalidEmailOrPassword),
        (Identifier.Kind.phone, AuthenticationError.invalidPhoneOrPassword),
        (Identifier.Kind.username, AuthenticationError.invalidUsernameOrPassword)
    ])
    func errorWhenInvalid(kind: Identifier.Kind, expected: AuthenticationError) {
        let identifier = Identifier(kind: kind, value: "test-value")
        #expect(identifier.errorWhenIdentifierIsInvalid == expected)
    }

    // MARK: - Kind Enum Tests

    @Test("Identifier kind raw values", arguments: [
        (Identifier.Kind.email, "email"),
        (Identifier.Kind.phone, "phone"),
        (Identifier.Kind.username, "username")
    ])
    func kindRawValues(kind: Identifier.Kind, expectedRawValue: String) {
        #expect(kind.rawValue == expectedRawValue)
    }

    @Test("Identifier kind from raw value", arguments: [
        ("email", Identifier.Kind.email),
        ("phone", Identifier.Kind.phone),
        ("username", Identifier.Kind.username)
    ])
    func kindFromRawValue(rawValue: String, expected: Identifier.Kind?) {
        #expect(Identifier.Kind(rawValue: rawValue) == expected)
    }

    @Test("Identifier kind from invalid raw value")
    func kindFromInvalidRawValue() {
        #expect(Identifier.Kind(rawValue: "invalid") == nil)
    }
}
