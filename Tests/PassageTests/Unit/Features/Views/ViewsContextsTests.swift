import Testing
import Vapor
@testable import Passage

@Suite("Views Contexts Tests")
struct ViewsContextsTests {

    // MARK: - Context Generic Type Tests

    @Test("Context initializes with theme and params")
    func contextInitialization() {
        struct TestParams: Sendable, Encodable {
            let value: String
        }

        let theme = Passage.Views.Theme(colors: .defaultLight)
        let params = TestParams(value: "test")
        let resolved = theme.resolve(for: .light)

        let context = Passage.Views.Context(theme: resolved, params: params)

        #expect(context.params.value == "test")
        #expect(context.theme.colors.primary == resolved.colors.primary)
    }

    // MARK: - LoginViewContext Tests

    @Test("LoginViewContext initialization")
    func loginViewContextInit() {
        let context = Passage.Views.LoginViewContext(
            byEmail: true,
            byPhone: false,
            byUsername: false,
            withApple: false,
            withGoogle: true,
            withGitHub: false,
            error: nil,
            success: nil,
            registerLink: "/register",
            resetPasswordLink: "/reset",
            byEmailMagicLink: nil,
            magicLinkRequestLink: nil
        )

        #expect(context.byEmail == true)
        #expect(context.byPhone == false)
        #expect(context.withGoogle == true)
        #expect(context.registerLink == "/register")
        #expect(context.resetPasswordLink == "/reset")
    }

    @Test("LoginViewContext copyWith updates only specified fields")
    func loginViewContextCopyWith() {
        let original = Passage.Views.LoginViewContext(
            byEmail: true,
            byPhone: false,
            byUsername: false,
            withApple: false,
            withGoogle: false,
            withGitHub: false,
            error: nil,
            success: nil,
            registerLink: nil,
            resetPasswordLink: nil,
            byEmailMagicLink: nil,
            magicLinkRequestLink: nil
        )

        let updated = original.copyWith(
            withGoogle: true,
            error: "An error occurred",
            registerLink: "/register"
        )

        // Updated fields
        #expect(updated.withGoogle == true)
        #expect(updated.error == "An error occurred")
        #expect(updated.registerLink == "/register")

        // Unchanged fields
        #expect(updated.byEmail == true)
        #expect(updated.byPhone == false)
        #expect(updated.withApple == false)
        #expect(updated.resetPasswordLink == nil)
    }

    @Test("LoginViewContext copyWith preserves original when no params")
    func loginViewContextCopyWithNoParams() {
        let original = Passage.Views.LoginViewContext(
            byEmail: true,
            byPhone: false,
            byUsername: false,
            withApple: true,
            withGoogle: false,
            withGitHub: false,
            error: "Original error",
            success: nil,
            registerLink: "/original",
            resetPasswordLink: "/reset",
            byEmailMagicLink: nil,
            magicLinkRequestLink: nil
        )

        let copy = original.copyWith()

        #expect(copy.byEmail == original.byEmail)
        #expect(copy.withApple == original.withApple)
        #expect(copy.error == original.error)
        #expect(copy.registerLink == original.registerLink)
    }

    // MARK: - RegisterViewContext Tests

    @Test("RegisterViewContext initialization")
    func registerViewContextInit() {
        let context = Passage.Views.RegisterViewContext(
            byEmail: true,
            byPhone: false,
            byUsername: false,
            withApple: false,
            withGoogle: true,
            withGitHub: false,
            error: nil,
            success: "Registration successful",
            loginLink: "/login"
        )

        #expect(context.byEmail == true)
        #expect(context.withGoogle == true)
        #expect(context.success == "Registration successful")
        #expect(context.loginLink == "/login")
    }

    @Test("RegisterViewContext copyWith updates only specified fields")
    func registerViewContextCopyWith() {
        let original = Passage.Views.RegisterViewContext(
            byEmail: true,
            byPhone: false,
            byUsername: false,
            withApple: false,
            withGoogle: false,
            withGitHub: false,
            error: nil,
            success: nil,
            loginLink: nil
        )

        let updated = original.copyWith(
            withGitHub: true,
            success: "Success message",
            loginLink: "/signin"
        )

        #expect(updated.withGitHub == true)
        #expect(updated.success == "Success message")
        #expect(updated.loginLink == "/signin")
        #expect(updated.byEmail == true)
        #expect(updated.withGoogle == false)
    }

    // MARK: - ResetPasswordRequestViewContext Tests

    @Test("ResetPasswordRequestViewContext initialization")
    func resetPasswordRequestContextInit() {
        let context = Passage.Views.ResetPasswordRequestViewContext(
            byEmail: true,
            byPhone: false,
            error: nil,
            success: nil
        )

        #expect(context.byEmail == true)
        #expect(context.byPhone == false)
        #expect(context.error == nil)
        #expect(context.success == nil)
    }

    @Test("ResetPasswordRequestViewContext copyWith updates fields")
    func resetPasswordRequestContextCopyWith() {
        let original = Passage.Views.ResetPasswordRequestViewContext(
            byEmail: true,
            byPhone: false,
            error: nil,
            success: nil
        )

        let updated = original.copyWith(
            error: "Invalid email",
            success: "Email sent"
        )

        #expect(updated.error == "Invalid email")
        #expect(updated.success == "Email sent")
        #expect(updated.byEmail == true)
    }

    @Test("ResetPasswordRequestViewContext with both email and phone")
    func resetPasswordRequestContextBothIdentifiers() {
        let context = Passage.Views.ResetPasswordRequestViewContext(
            byEmail: true,
            byPhone: true,
            error: nil,
            success: nil
        )

        #expect(context.byEmail == true)
        #expect(context.byPhone == true)
    }

    // MARK: - ResetPasswordConfirmViewContext Tests

    @Test("ResetPasswordConfirmViewContext initialization")
    func resetPasswordConfirmContextInit() {
        let context = Passage.Views.ResetPasswordConfirmViewContext(
            byEmail: true,
            byPhone: false,
            code: "ABC123",
            email: "test@example.com",
            error: nil,
            success: nil
        )

        #expect(context.byEmail == true)
        #expect(context.code == "ABC123")
        #expect(context.email == "test@example.com")
    }

    @Test("ResetPasswordConfirmViewContext copyWith preserves code")
    func resetPasswordConfirmContextCopyWithPreservesCode() {
        let original = Passage.Views.ResetPasswordConfirmViewContext(
            byEmail: true,
            byPhone: false,
            code: "ORIGINAL_CODE",
            email: "original@example.com",
            error: nil,
            success: nil
        )

        let updated = original.copyWith(
            email: "new@example.com",
            error: "Invalid code"
        )

        // Code should be preserved
        #expect(updated.code == "ORIGINAL_CODE")
        #expect(updated.email == "new@example.com")
        #expect(updated.error == "Invalid code")
    }

    @Test("ResetPasswordConfirmViewContext copyWith updates specified fields")
    func resetPasswordConfirmContextCopyWith() {
        let original = Passage.Views.ResetPasswordConfirmViewContext(
            byEmail: true,
            byPhone: false,
            code: "123456",
            email: nil,
            error: nil,
            success: nil
        )

        let updated = original.copyWith(
            byPhone: true,
            email: "test@example.com",
            success: "Password reset successful"
        )

        #expect(updated.byPhone == true)
        #expect(updated.email == "test@example.com")
        #expect(updated.success == "Password reset successful")
        #expect(updated.code == "123456")
    }

    // MARK: - Content Conformance Tests

    @Test("LoginViewContext conforms to Content")
    func loginViewContextConformsToContent() {
        let context = Passage.Views.LoginViewContext(
            byEmail: true, byPhone: false, byUsername: false,
            withApple: false, withGoogle: false, withGitHub: false,
            error: nil, success: nil, registerLink: nil, resetPasswordLink: nil,
            byEmailMagicLink: nil, magicLinkRequestLink: nil
        )
        let _: any Content = context
    }

    @Test("RegisterViewContext conforms to Content")
    func registerViewContextConformsToContent() {
        let context = Passage.Views.RegisterViewContext(
            byEmail: true, byPhone: false, byUsername: false,
            withApple: false, withGoogle: false, withGitHub: false,
            error: nil, success: nil, loginLink: nil
        )
        let _: any Content = context
    }

    @Test("ResetPasswordRequestViewContext conforms to Content")
    func resetPasswordRequestContextConformsToContent() {
        let context = Passage.Views.ResetPasswordRequestViewContext(
            byEmail: true, byPhone: false,
            error: nil, success: nil
        )
        let _: any Content = context
    }

    @Test("ResetPasswordConfirmViewContext conforms to Content")
    func resetPasswordConfirmContextConformsToContent() {
        let context = Passage.Views.ResetPasswordConfirmViewContext(
            byEmail: true, byPhone: false,
            code: "123", email: nil,
            error: nil, success: nil
        )
        let _: any Content = context
    }

    // MARK: - Context Immutability Tests

    @Test("LoginViewContext copyWith creates new instance")
    func loginViewContextCopyWithCreatesNewInstance() {
        let original = Passage.Views.LoginViewContext(
            byEmail: true, byPhone: false, byUsername: false,
            withApple: false, withGoogle: false, withGitHub: false,
            error: nil, success: nil, registerLink: nil, resetPasswordLink: nil,
            byEmailMagicLink: nil, magicLinkRequestLink: nil
        )

        let copy = original.copyWith(error: "New error")

        // Original should be unchanged
        #expect(original.error == nil)
        #expect(copy.error == "New error")
    }

    @Test("RegisterViewContext copyWith creates new instance")
    func registerViewContextCopyWithCreatesNewInstance() {
        let original = Passage.Views.RegisterViewContext(
            byEmail: true, byPhone: false, byUsername: false,
            withApple: false, withGoogle: false, withGitHub: false,
            error: nil, success: nil, loginLink: nil
        )

        let copy = original.copyWith(success: "Success!")

        #expect(original.success == nil)
        #expect(copy.success == "Success!")
    }
}
