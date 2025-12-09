import Testing
@testable import Passage

@Suite("Sessions Configuration Tests")
struct SessionConfigurationTests {

    // MARK: - Initialization Tests

    @Test("Sessions configuration initializes with default values")
    func initializesWithDefaultValues() {
        let session = Passage.Configuration.Sessions()

        #expect(session.enabled == false)
    }

    @Test("Sessions configuration initializes with enabled true")
    func initializesWithEnabledTrue() {
        let session = Passage.Configuration.Sessions(enabled: true)

        #expect(session.enabled == true)
    }

    @Test("Sessions configuration initializes with enabled false")
    func initializesWithEnabledFalse() {
        let session = Passage.Configuration.Sessions(enabled: false)

        #expect(session.enabled == false)
    }

    // MARK: - Protocol Conformance Tests

    @Test("Sessions configuration conforms to Sendable")
    func conformsToSendable() {
        func acceptsSendable<T: Sendable>(_ type: T.Type) {}
        acceptsSendable(Passage.Configuration.Sessions.self)
    }

    // MARK: - Type Tests

    @Test("Sessions configuration type name is correct")
    func typeNameIsCorrect() {
        let typeName = String(describing: Passage.Configuration.Sessions.self)
        #expect(typeName == "Sessions")
    }
}
