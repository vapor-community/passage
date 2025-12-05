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

    // MARK: - asCredential() Tests

    @Test("RegisterForm asCredential returns email credential")
    func asCredentialWithEmail() throws {
        let form = MockRegisterForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )

        let credential = try form.asCredential(hash: "hashed_password")
        #expect(credential.identifier.kind == .email)
        #expect(credential.identifier.value == "test@example.com")
        #expect(credential.passwordHash == "hashed_password")
    }

    @Test("RegisterForm asCredential returns phone credential")
    func asCredentialWithPhone() throws {
        let form = MockRegisterForm(
            email: nil,
            phone: "+1234567890",
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )

        let credential = try form.asCredential(hash: "hashed_password")
        #expect(credential.identifier.kind == .phone)
        #expect(credential.identifier.value == "+1234567890")
        #expect(credential.passwordHash == "hashed_password")
    }

    @Test("RegisterForm asCredential returns username credential")
    func asCredentialWithUsername() throws {
        let form = MockRegisterForm(
            email: nil,
            phone: nil,
            username: "johndoe",
            password: "password123",
            confirmPassword: "password123"
        )

        let credential = try form.asCredential(hash: "hashed_password")
        #expect(credential.identifier.kind == .username)
        #expect(credential.identifier.value == "johndoe")
        #expect(credential.passwordHash == "hashed_password")
    }

    @Test("RegisterForm asCredential prefers email over phone")
    func asCredentialPrefersEmail() throws {
        let form = MockRegisterForm(
            email: "test@example.com",
            phone: "+1234567890",
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )

        let credential = try form.asCredential(hash: "hashed_password")
        #expect(credential.identifier.kind == .email)
        #expect(credential.identifier.value == "test@example.com")
    }

    @Test("RegisterForm asCredential throws when no identifier provided")
    func asCredentialThrowsWhenNoIdentifier() {
        let form = MockRegisterForm(
            email: nil,
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )

        #expect(throws: AuthenticationError.identifierNotSpecified) {
            _ = try form.asCredential(hash: "hashed_password")
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
