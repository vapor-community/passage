import Testing
import Vapor
@testable import Passage

@Suite("LoginForm Protocol Tests")
struct LoginFormProtocolTests {

    // MARK: - Mock Implementations

    struct MockLoginFormWithEmail: LoginForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String?.self, is: .email || .nil, required: false)
            validations.add("password", as: String.self, is: .count(6...))
        }

        let email: String?
        let phone: String?
        let username: String?
        let password: String

        func validate() throws {
            // No additional validation
        }
    }

    struct MockLoginFormWithPhone: LoginForm {
        static func validations(_ validations: inout Validations) {
            validations.add("phone", as: String?.self, required: false)
            validations.add("password", as: String.self, is: .count(6...))
        }

        let email: String?
        let phone: String?
        let username: String?
        let password: String

        func validate() throws {
            // No additional validation
        }
    }

    struct MockLoginFormWithUsername: LoginForm {
        static func validations(_ validations: inout Validations) {
            validations.add("username", as: String?.self, required: false)
            validations.add("password", as: String.self, is: .count(6...))
        }

        let email: String?
        let phone: String?
        let username: String?
        let password: String

        func validate() throws {
            // No additional validation
        }
    }

    // MARK: - asIdentifier() Tests

    @Test("LoginForm asIdentifier returns email identifier")
    func asIdentifierWithEmail() throws {
        let form = MockLoginFormWithEmail(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123"
        )

        let identifier = try form.asIdentifier()
        #expect(identifier.kind == .email)
        #expect(identifier.value == "test@example.com")
    }

    @Test("LoginForm asIdentifier returns phone identifier")
    func asIdentifierWithPhone() throws {
        let form = MockLoginFormWithPhone(
            email: nil,
            phone: "+1234567890",
            username: nil,
            password: "password123"
        )

        let identifier = try form.asIdentifier()
        #expect(identifier.kind == .phone)
        #expect(identifier.value == "+1234567890")
    }

    @Test("LoginForm asIdentifier returns username identifier")
    func asIdentifierWithUsername() throws {
        let form = MockLoginFormWithUsername(
            email: nil,
            phone: nil,
            username: "johndoe",
            password: "password123"
        )

        let identifier = try form.asIdentifier()
        #expect(identifier.kind == .username)
        #expect(identifier.value == "johndoe")
    }

    @Test("LoginForm asIdentifier prefers email over phone")
    func asIdentifierPrefersEmail() throws {
        let form = MockLoginFormWithEmail(
            email: "test@example.com",
            phone: "+1234567890",
            username: nil,
            password: "password123"
        )

        let identifier = try form.asIdentifier()
        #expect(identifier.kind == .email)
        #expect(identifier.value == "test@example.com")
    }

    @Test("LoginForm asIdentifier prefers email over username")
    func asIdentifierPrefersEmailOverUsername() throws {
        let form = MockLoginFormWithEmail(
            email: "test@example.com",
            phone: nil,
            username: "johndoe",
            password: "password123"
        )

        let identifier = try form.asIdentifier()
        #expect(identifier.kind == .email)
        #expect(identifier.value == "test@example.com")
    }

    @Test("LoginForm asIdentifier prefers phone over username")
    func asIdentifierPrefersPhoneOverUsername() throws {
        let form = MockLoginFormWithPhone(
            email: nil,
            phone: "+1234567890",
            username: "johndoe",
            password: "password123"
        )

        let identifier = try form.asIdentifier()
        #expect(identifier.kind == .phone)
        #expect(identifier.value == "+1234567890")
    }

    @Test("LoginForm asIdentifier throws when no identifier provided")
    func asIdentifierThrowsWhenNoIdentifier() {
        let form = MockLoginFormWithEmail(
            email: nil,
            phone: nil,
            username: nil,
            password: "password123"
        )

        #expect(throws: AuthenticationError.identifierNotSpecified) {
            _ = try form.asIdentifier()
        }
    }

    // MARK: - Protocol Conformance Tests

    @Test("LoginForm conforms to Form protocol")
    func loginFormConformsToForm() {
        let form: any Form = MockLoginFormWithEmail(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123"
        )
        #expect(form is MockLoginFormWithEmail)
    }

    @Test("LoginForm has required properties")
    func loginFormRequiredProperties() {
        let form = MockLoginFormWithEmail(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123"
        )

        #expect(form.email == "test@example.com")
        #expect(form.phone == nil)
        #expect(form.username == nil)
        #expect(form.password == "password123")
    }
}
