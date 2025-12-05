import Testing
import Vapor
@testable import Passage

@Suite("Passage Struct Tests")
struct PassageStructTests {

    // MARK: - Passage Struct Tests

    @Test("Passage struct is properly namespaced")
    func passageNamespace() {
        let typeName = String(reflecting: Passage.self)
        #expect(typeName.contains("Passage"))
    }

    @Test("Passage struct conforms to Sendable")
    func passageSendable() {
        #expect(Passage.self is any Sendable.Type)
    }

    // MARK: - Storage Nested Type Tests

    @Test("Storage is nested within Passage")
    func storageNesting() {
        let typeName = String(reflecting: Passage.Storage.self)
        #expect(typeName.contains("Passage.Storage"))
    }

    @Test("Storage.Key is nested within Storage")
    func storageKeyNesting() {
        let typeName = String(reflecting: Passage.Storage.Key.self)
        #expect(typeName.contains("Passage.Storage.Key"))
    }

    @Test("Storage.Key conforms to StorageKey protocol")
    func storageKeyProtocol() {
        #expect(Passage.Storage.Key.self is any StorageKey.Type)
    }

    @Test("Storage.Key.Value is Storage type")
    func storageKeyValue() {
        let valueType = Passage.Storage.Key.Value.self
        #expect(valueType == Passage.Storage.self)
    }
}
