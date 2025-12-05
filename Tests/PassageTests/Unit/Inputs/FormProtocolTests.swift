import Testing
import Vapor
@testable import Passage

@Suite("Form Protocol Tests")
struct FormProtocolTests {

    // MARK: - Mock Implementation

    struct MockForm: Form {
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty)
        }

        let name: String
    }

    struct MockFormWithValidation: Form {
        static func validations(_ validations: inout Validations) {
            validations.add("value", as: Int.self, is: .range(1...100))
        }

        let value: Int

        func validate() throws {
            if value < 10 {
                throw Abort(.badRequest, reason: "Value must be at least 10")
            }
        }
    }

    struct MockFormNoExtraValidation: Form {
        static func validations(_ validations: inout Validations) {
            validations.add("data", as: String.self, is: !.empty)
        }

        let data: String
        // No validate() override - uses default implementation
    }

    // MARK: - Protocol Conformance Tests

    @Test("Form protocol can be implemented")
    func formProtocolImplementation() {
        let form = MockForm(name: "test")
        let _: any Form = form
        #expect(form.name == "test")
    }

    @Test("Form protocol conforms to Content")
    func formProtocolConformsToContent() {
        let form = MockForm(name: "test")
        let _: any Content = form
        #expect(form is Content)
    }

    @Test("Form protocol conforms to Validatable")
    func formProtocolConformsToValidatable() {
        let form = MockForm(name: "test")
        let _: any Validatable = form
        #expect(form is Validatable)
    }

    // MARK: - Default validate() Implementation Tests

    @Test("Form default validate() does nothing")
    func formDefaultValidateDoesNothing() throws {
        let form = MockFormNoExtraValidation(data: "test data")
        try form.validate() // Should not throw
    }

    // MARK: - Custom validate() Implementation Tests

    @Test("Form custom validate() can throw errors")
    func formCustomValidateCanThrow() {
        let form = MockFormWithValidation(value: 5)

        #expect(throws: (any Error).self) {
            try form.validate()
        }
    }

    @Test("Form custom validate() succeeds when valid")
    func formCustomValidateSucceeds() throws {
        let form = MockFormWithValidation(value: 50)
        try form.validate() // Should not throw
    }

    // MARK: - Multiple Form Implementations Tests

    @Test("Multiple Form implementations can coexist")
    func multipleFormImplementations() {
        let form1: any Form = MockForm(name: "test1")
        let form2: any Form = MockFormWithValidation(value: 25)
        let form3: any Form = MockFormNoExtraValidation(data: "test3")

        #expect(form1 is MockForm)
        #expect(form2 is MockFormWithValidation)
        #expect(form3 is MockFormNoExtraValidation)
    }

    // MARK: - Form Properties Tests

    @Test("Form can have properties")
    func formCanHaveProperties() {
        let form = MockForm(name: "test name")
        #expect(form.name == "test name")
    }

    @Test("Form can have computed properties")
    func formCanHaveComputedProperties() {
        struct FormWithComputed: Form {
            static func validations(_ validations: inout Validations) {}

            let firstName: String
            let lastName: String

            var fullName: String {
                "\(firstName) \(lastName)"
            }
        }

        let form = FormWithComputed(firstName: "John", lastName: "Doe")
        #expect(form.fullName == "John Doe")
    }
}
