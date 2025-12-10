import Testing
@testable import Passage

@Suite("Account Struct Tests", .tags(.unit))
struct AccountStructTests {

    // MARK: - Structure Tests

    @Test("Account struct is properly namespaced in Passage")
    func accountStructIsProperlyNamespaced() {
        // Verify the Account struct type name
        let typeName = String(describing: Passage.Account.self)
        #expect(typeName == "Account")
    }

    // MARK: - Feature Organization Tests

    @Test("Account feature is properly namespaced")
    func accountFeatureNamespace() {
        // Verify Account is correctly nested within Passage namespace
        let typeName = String(reflecting: Passage.Account.self)
        #expect(typeName.contains("Passage.Account"))
    }
}
