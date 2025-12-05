import Testing
import Vapor
@testable import Passage

@Suite("Views Forms Tests")
struct ViewsFormsTests {

    // MARK: - PasswordResetRequestForm Tests

    @Test("PasswordResetRequestForm with email creates email identifier")
    func resetRequestFormWithEmail() throws {
        let form = PasswordResetRequestForm(
            email: "test@example.com",
            phone: nil
        )

        let identifier = try form.asIdentifier()

        #expect(identifier.kind == .email)
        #expect(identifier.value == "test@example.com")
    }

    @Test("PasswordResetRequestForm with phone creates phone identifier")
    func resetRequestFormWithPhone() throws {
        let form = PasswordResetRequestForm(
            email: nil,
            phone: "+1234567890"
        )

        let identifier = try form.asIdentifier()

        #expect(identifier.kind == .phone)
        #expect(identifier.value == "+1234567890")
    }

    @Test("PasswordResetRequestForm prefers email over phone when both provided")
    func resetRequestFormPrefersEmail() throws {
        let form = PasswordResetRequestForm(
            email: "test@example.com",
            phone: "+1234567890"
        )

        let identifier = try form.asIdentifier()

        #expect(identifier.kind == .email)
        #expect(identifier.value == "test@example.com")
    }

    @Test("PasswordResetRequestForm throws when neither email nor phone provided")
    func resetRequestFormThrowsWithoutIdentifier() {
        let form = PasswordResetRequestForm(
            email: nil,
            phone: nil
        )

        #expect(throws: AuthenticationError.self) {
            try form.asIdentifier()
        }
    }

    @Test("PasswordResetRequestForm validation succeeds with email")
    func resetRequestFormValidationWithEmail() throws {
        let form = PasswordResetRequestForm(
            email: "test@example.com",
            phone: nil
        )

        try form.validate()
    }

    @Test("PasswordResetRequestForm validation succeeds with phone")
    func resetRequestFormValidationWithPhone() throws {
        let form = PasswordResetRequestForm(
            email: nil,
            phone: "+1234567890"
        )

        try form.validate()
    }

    @Test("PasswordResetRequestForm validation fails when neither provided")
    func resetRequestFormValidationFails() {
        let form = PasswordResetRequestForm(
            email: nil,
            phone: nil
        )

        #expect(throws: (any Error).self) {
            try form.validate()
        }
    }

    // MARK: - PasswordResetConfirmForm Tests

    @Test("PasswordResetConfirmForm with email creates email identifier")
    func resetConfirmFormWithEmail() throws {
        let form = PasswordResetConfirmForm(
            email: "test@example.com",
            phone: nil,
            code: "123456",
            newPassword: "newpassword123",
            confirmPassword: "newpassword123"
        )

        let identifier = try form.asIdentifier()

        #expect(identifier.kind == .email)
        #expect(identifier.value == "test@example.com")
    }

    @Test("PasswordResetConfirmForm with phone creates phone identifier")
    func resetConfirmFormWithPhone() throws {
        let form = PasswordResetConfirmForm(
            email: nil,
            phone: "+1234567890",
            code: "123456",
            newPassword: "newpassword123",
            confirmPassword: "newpassword123"
        )

        let identifier = try form.asIdentifier()

        #expect(identifier.kind == .phone)
        #expect(identifier.value == "+1234567890")
    }

    @Test("PasswordResetConfirmForm prefers email over phone when both provided")
    func resetConfirmFormPrefersEmail() throws {
        let form = PasswordResetConfirmForm(
            email: "test@example.com",
            phone: "+1234567890",
            code: "123456",
            newPassword: "newpassword123",
            confirmPassword: "newpassword123"
        )

        let identifier = try form.asIdentifier()

        #expect(identifier.kind == .email)
        #expect(identifier.value == "test@example.com")
    }

    @Test("PasswordResetConfirmForm throws when neither email nor phone provided")
    func resetConfirmFormThrowsWithoutIdentifier() {
        let form = PasswordResetConfirmForm(
            email: nil,
            phone: nil,
            code: "123456",
            newPassword: "newpassword123",
            confirmPassword: "newpassword123"
        )

        #expect(throws: AuthenticationError.self) {
            try form.asIdentifier()
        }
    }

    @Test("PasswordResetConfirmForm validation succeeds with matching passwords")
    func resetConfirmFormValidationWithMatchingPasswords() throws {
        let form = PasswordResetConfirmForm(
            email: "test@example.com",
            phone: nil,
            code: "123456",
            newPassword: "validpassword123",
            confirmPassword: "validpassword123"
        )

        try form.validate()
    }

    @Test("PasswordResetConfirmForm validation fails when passwords don't match")
    func resetConfirmFormValidationFailsWithMismatch() {
        let form = PasswordResetConfirmForm(
            email: "test@example.com",
            phone: nil,
            code: "123456",
            newPassword: "password1",
            confirmPassword: "password2"
        )

        #expect(throws: (any Error).self) {
            try form.validate()
        }
    }

    @Test("PasswordResetConfirmForm validation fails when neither email nor phone provided")
    func resetConfirmFormValidationFailsWithoutIdentifier() {
        let form = PasswordResetConfirmForm(
            email: nil,
            phone: nil,
            code: "123456",
            newPassword: "validpassword123",
            confirmPassword: "validpassword123"
        )

        #expect(throws: (any Error).self) {
            try form.validate()
        }
    }

    @Test("PasswordResetConfirmForm stores code correctly")
    func resetConfirmFormStoresCode() {
        let form = PasswordResetConfirmForm(
            email: "test@example.com",
            phone: nil,
            code: "ABC123",
            newPassword: "validpassword123",
            confirmPassword: "validpassword123"
        )

        #expect(form.code == "ABC123")
    }

    @Test("PasswordResetConfirmForm stores passwords correctly")
    func resetConfirmFormStoresPasswords() {
        let form = PasswordResetConfirmForm(
            email: "test@example.com",
            phone: nil,
            code: "123456",
            newPassword: "mynewpassword",
            confirmPassword: "mynewpassword"
        )

        #expect(form.newPassword == "mynewpassword")
        #expect(form.confirmPassword == "mynewpassword")
    }

    // MARK: - Content Conformance Tests

    @Test("PasswordResetRequestForm conforms to Content")
    func resetRequestFormConformsToContent() {
        let form = PasswordResetRequestForm(email: "test@example.com", phone: nil)
        let _: any Content = form
    }

    @Test("PasswordResetConfirmForm conforms to Content")
    func resetConfirmFormConformsToContent() {
        let form = PasswordResetConfirmForm(
            email: "test@example.com",
            phone: nil,
            code: "123456",
            newPassword: "password",
            confirmPassword: "password"
        )
        let _: any Content = form
    }

    // MARK: - Validatable Conformance Tests

    @Test("PasswordResetRequestForm conforms to Validatable")
    func resetRequestFormConformsToValidatable() {
        let form = PasswordResetRequestForm(email: "test@example.com", phone: nil)
        let _: any Validatable = form
    }

    @Test("PasswordResetConfirmForm conforms to Validatable")
    func resetConfirmFormConformsToValidatable() {
        let form = PasswordResetConfirmForm(
            email: "test@example.com",
            phone: nil,
            code: "123456",
            newPassword: "password123",
            confirmPassword: "password123"
        )
        let _: any Validatable = form
    }
}
