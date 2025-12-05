import Testing
@testable import Passage

@Suite("Identity Struct Tests")
struct IdentityStructTests {

    // MARK: - Structure Tests

    @Test("Identity struct is properly namespaced in Passage")
    func identityStructIsProperlyNamespaced() {
        // Verify the Identity struct type name
        let typeName = String(describing: Passage.Identity.self)
        #expect(typeName == "Identity")
    }

    // MARK: - Feature Organization Tests

    @Test("Identity feature is properly namespaced")
    func identityFeatureNamespace() {
        // Verify Identity is correctly nested within Passage namespace
        let typeName = String(reflecting: Passage.Identity.self)
        #expect(typeName.contains("Passage.Identity"))
    }
}
