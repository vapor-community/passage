import Testing
import Vapor
import JWT
@testable import Passage

@Suite("PassageBearerAuthenticator Tests")
struct PassageBearerAuthenticatorTests {

    // MARK: - Structure Tests

    @Test("PassageBearerAuthenticator can be initialized")
    func canBeInitialized() {
        let authenticator = PassageBearerAuthenticator()
        #expect(authenticator != nil)
    }

    @Test("PassageBearerAuthenticator type name is correct")
    func typeNameIsCorrect() {
        let typeName = String(describing: PassageBearerAuthenticator.self)
        #expect(typeName == "PassageBearerAuthenticator")
    }

    // MARK: - Protocol Conformance Tests

    @Test("PassageBearerAuthenticator conforms to JWTAuthenticator")
    func conformsToJWTAuthenticator() {
        let authenticator = PassageBearerAuthenticator()
        #expect(authenticator is any JWTAuthenticator)
    }

    @Test("PassageBearerAuthenticator Payload typealias is AccessToken")
    func payloadTypealiasIsAccessToken() {
        // Verify the Payload typealias by checking the type
        let payloadType = PassageBearerAuthenticator.Payload.self
        #expect(payloadType == AccessToken.self)
    }
}

@Suite("PassageSessionAuthenticator Tests")
struct PassageSessionAuthenticatorTests {

    // MARK: - Structure Tests

    @Test("PassageSessionAuthenticator can be initialized")
    func canBeInitialized() {
        let authenticator = PassageSessionAuthenticator()
        #expect(authenticator != nil)
    }

    @Test("PassageSessionAuthenticator type name is correct")
    func typeNameIsCorrect() {
        let typeName = String(describing: PassageSessionAuthenticator.self)
        #expect(typeName == "PassageSessionAuthenticator")
    }

    // MARK: - Protocol Conformance Tests

    @Test("PassageSessionAuthenticator conforms to AsyncAuthenticator")
    func conformsToAsyncAuthenticator() {
        let authenticator = PassageSessionAuthenticator()
        #expect(authenticator is any AsyncAuthenticator)
    }

    @Test("PassageSessionAuthenticator conforms to AsyncMiddleware")
    func conformsToAsyncMiddleware() {
        let authenticator = PassageSessionAuthenticator()
        #expect(authenticator is any AsyncMiddleware)
    }
}
