import Testing
import Vapor
@testable import Passage

@Suite("RegisterForm Protocol Tests")
struct RegisterFormProtocolTests {

    // MARK: - Mock Implementation

    struct MockRegisterForm: RegisterForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String?.self, is: .email || .nil, required: false)
            validations.add("password", as: String.self, is: .count(6...))
            validations.add("confirmPassword", as: String.self, is: .count(6...))
        }

        let email: String?
        let phone: String?
        let username: String?
        let password: String
        let confirmPassword: String

        func validate() throws {
            if password != confirmPassword {
                throw Abort(.badRequest, reason: "Passwords do not match")
            }
        }
    }

    // MARK: - asIdentifier() Tests

    @Test("RegisterForm asIdentifier returns email identifier")
    func asIdentifierWithEmail() throws {
        let form = MockRegisterForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )

        let identifier = try form.asIdentifier()
        #expect(identifier.kind == .email)
        #expect(identifier.value == "test@example.com")
    }

    @Test("RegisterForm asIdentifier returns phone identifier")
    func asIdentifierWithPhone() throws {
        let form = MockRegisterForm(
            email: nil,
            phone: "+1234567890",
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )

        let identifier = try form.asIdentifier()
        #expect(identifier.kind == .phone)
        #expect(identifier.value == "+1234567890")
    }

    @Test("RegisterForm asIdentifier returns username identifier")
    func asIdentifierWithUsername() throws {
        let form = MockRegisterForm(
            email: nil,
            phone: nil,
            username: "johndoe",
            password: "password123",
            confirmPassword: "password123"
        )

        let identifier = try form.asIdentifier()
        #expect(identifier.kind == .username)
        #expect(identifier.value == "johndoe")
    }

    @Test("RegisterForm asIdentifier prefers email over phone")
    func asIdentifierPrefersEmail() throws {
        let form = MockRegisterForm(
            email: "test@example.com",
            phone: "+1234567890",
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )

        let identifier = try form.asIdentifier()
        #expect(identifier.kind == .email)
        #expect(identifier.value == "test@example.com")
    }

    @Test("RegisterForm asIdentifier throws when no identifier provided")
    func asIdentifierThrowsWhenNoIdentifier() {
        let form = MockRegisterForm(
            email: nil,
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )

        #expect(throws: AuthenticationError.identifierNotSpecified) {
            _ = try form.asIdentifier()
        }
    }

    // MARK: - Protocol Conformance Tests

    @Test("RegisterForm conforms to Form protocol")
    func registerFormConformsToForm() {
        let form: any Form = MockRegisterForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )
        #expect(form is MockRegisterForm)
    }

    @Test("RegisterForm has required properties")
    func registerFormRequiredProperties() {
        let form = MockRegisterForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )

        #expect(form.email == "test@example.com")
        #expect(form.phone == nil)
        #expect(form.username == nil)
        #expect(form.password == "password123")
        #expect(form.confirmPassword == "password123")
    }

    // MARK: - Password Validation Tests

    @Test("RegisterForm validate succeeds when passwords match")
    func validateSucceedsWhenPasswordsMatch() throws {
        let form = MockRegisterForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )

        try form.validate() // Should not throw
    }

    @Test("RegisterForm validate throws when passwords don't match")
    func validateThrowsWhenPasswordsDontMatch() {
        let form = MockRegisterForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "different_password"
        )

        #expect(throws: (any Error).self) {
            try form.validate()
        }
    }
}
