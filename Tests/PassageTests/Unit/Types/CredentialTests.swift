import Testing
@testable import Passage

@Suite("Credential Tests")
struct CredentialTests {

    // MARK: - Credential Struct Tests

    @Test("Credential password initialization")
    func credentialPasswordInitialization() {
        let credential = Credential(kind: .password, secret: "hashed-password-123")

        #expect(credential.kind == Credential.Kind.password)
        #expect(credential.secret == "hashed-password-123")
    }

    @Test("Credential password convenience initializer")
    func credentialPasswordConvenienceInitializer() {
        let credential = Credential.password("hashed-password-456")

        #expect(credential.kind == Credential.Kind.password)
        #expect(credential.secret == "hashed-password-456")
    }

    @Test("Credential kind raw value")
    func credentialKindRawValue() {
        #expect(Credential.Kind.password.rawValue == "password")
    }

    @Test("Credential kind from raw value")
    func credentialKindFromRawValue() {
        #expect(Credential.Kind(rawValue: "password") == Credential.Kind.password)
        #expect(Credential.Kind(rawValue: "invalid") == nil)
    }
}
