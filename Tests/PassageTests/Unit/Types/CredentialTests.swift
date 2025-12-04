import Testing
@testable import Passage

@Suite("Credential Tests")
struct CredentialTests {

    // MARK: - Identifier Tests

    @Test("Credential identifier extraction", arguments: [
        (Credential.email(email: "test@example.com", passwordHash: "hash1"), Identifier.Kind.email, "test@example.com"),
        (Credential.phone(phone: "+1234567890", passwordHash: "hash2"), Identifier.Kind.phone, "+1234567890"),
        (Credential.username(username: "johndoe", passwordHash: "hash3"), Identifier.Kind.username, "johndoe")
    ])
    func credentialIdentifier(credential: Credential, expectedKind: Identifier.Kind, expectedValue: String) {
        let identifier = credential.identifier

        #expect(identifier.kind == expectedKind)
        #expect(identifier.value == expectedValue)
    }

    @Test("Credential identifier kind", arguments: [
        (Credential.email(email: "test@example.com", passwordHash: "hash"), Identifier.Kind.email),
        (Credential.phone(phone: "+1234567890", passwordHash: "hash"), Identifier.Kind.phone),
        (Credential.username(username: "johndoe", passwordHash: "hash"), Identifier.Kind.username)
    ])
    func credentialIdentifierKind(credential: Credential, expected: Identifier.Kind) {
        #expect(credential.identifierKind == expected)
    }

    @Test("Credential identifier value", arguments: [
        (Credential.email(email: "test@example.com", passwordHash: "hash"), "test@example.com"),
        (Credential.phone(phone: "+1234567890", passwordHash: "hash"), "+1234567890"),
        (Credential.username(username: "johndoe", passwordHash: "hash"), "johndoe")
    ])
    func credentialIdentifierValue(credential: Credential, expected: String) {
        #expect(credential.identifierValue == expected)
    }

    // MARK: - Password Hash Tests

    @Test("Credential password hash", arguments: [
        (Credential.email(email: "test@example.com", passwordHash: "hash123"), "hash123"),
        (Credential.phone(phone: "+1234567890", passwordHash: "hash456"), "hash456"),
        (Credential.username(username: "johndoe", passwordHash: "hash789"), "hash789")
    ])
    func credentialPasswordHash(credential: Credential, expected: String) {
        #expect(credential.passwordHash == expected)
    }

    // MARK: - Error Support Tests

    @Test("Credential error when already registered", arguments: [
        (Credential.email(email: "test@example.com", passwordHash: "hash"), AuthenticationError.emailAlreadyRegistered),
        (Credential.phone(phone: "+1234567890", passwordHash: "hash"), AuthenticationError.phoneAlreadyRegistered),
        (Credential.username(username: "johndoe", passwordHash: "hash"), AuthenticationError.usernameAlreadyRegistered)
    ])
    func errorWhenAlreadyRegistered(credential: Credential, expected: AuthenticationError) {
        #expect(credential.errorWhenIdentifierAlreadyRegistered == expected)
    }

    @Test("Credential error when invalid", arguments: [
        (Credential.email(email: "test@example.com", passwordHash: "hash"), AuthenticationError.invalidEmailOrPassword),
        (Credential.phone(phone: "+1234567890", passwordHash: "hash"), AuthenticationError.invalidPhoneOrPassword),
        (Credential.username(username: "johndoe", passwordHash: "hash"), AuthenticationError.invalidUsernameOrPassword)
    ])
    func errorWhenInvalid(credential: Credential, expected: AuthenticationError) {
        #expect(credential.errorWhenIdentifierIsInvalid == expected)
    }

    @Test("Credential error when not verified", arguments: [
        (Credential.email(email: "test@example.com", passwordHash: "hash"), AuthenticationError.emailIsNotVerified),
        (Credential.phone(phone: "+1234567890", passwordHash: "hash"), AuthenticationError.phoneIsNotVerified),
        (Credential.username(username: "johndoe", passwordHash: "hash"), AuthenticationError.invalidUsernameOrPassword)
    ])
    func errorWhenNotVerified(credential: Credential, expected: AuthenticationError) {
        #expect(credential.errorWhenIdentifierNotVerified == expected)
    }
}
