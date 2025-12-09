import Testing
import Vapor
@testable import Passage

@Suite("PassageContext Tests")
struct PassageContextTests {

    // MARK: - Structure Tests

    @Test("PassageContext type name is correct")
    func typeNameIsCorrect() {
        let typeName = String(describing: PassageContext.self)
        #expect(typeName == "PassageContext")
    }

    // MARK: - Protocol Conformance Tests

    @Test("PassageContext conforms to Sendable")
    func conformsToSendable() {
        // This test verifies at compile time that PassageContext is Sendable
        // If PassageContext didn't conform to Sendable, this would fail to compile
        func acceptsSendable<T: Sendable>(_ type: T.Type) {}
        acceptsSendable(PassageContext.self)
    }

    // MARK: - Public Interface Tests

    @Test("PassageContext has user property")
    func hasUserProperty() {
        // Verify PassageContext has a user property that throws
        // This is a compile-time check - if the property doesn't exist, this won't compile
        func checkUserProperty(_ context: PassageContext) throws -> any User {
            try context.user
        }
        // Test passes if it compiles
    }

    @Test("PassageContext has hasUser property")
    func hasHasUserProperty() {
        // Verify PassageContext has a hasUser bool property
        func checkHasUserProperty(_ context: PassageContext) -> Bool {
            context.hasUser
        }
        // Test passes if it compiles
    }

    @Test("PassageContext has login method")
    func hasLoginMethod() {
        // Verify PassageContext has a login method that accepts a User
        func checkLoginMethod(_ context: PassageContext, _ user: any User) {
            context.login(user)
        }
        // Test passes if it compiles
    }

    @Test("PassageContext has logout method")
    func hasLogoutMethod() {
        // Verify PassageContext has a logout method
        func checkLogoutMethod(_ context: PassageContext) {
            context.logout()
        }
        // Test passes if it compiles
    }
}
