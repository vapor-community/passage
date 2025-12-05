import Testing
import Vapor
@testable import Passage

@Suite("Other Form Protocols Tests")
struct OtherFormProtocolsTests {

    // MARK: - RefreshTokenForm Tests

    struct MockRefreshTokenForm: RefreshTokenForm {
        static func validations(_ validations: inout Validations) {
            validations.add("refreshToken", as: String.self, is: !.empty)
        }

        let refreshToken: String

        func validate() throws {
            // No additional validation
        }
    }

    @Test("RefreshTokenForm conforms to Form protocol")
    func refreshTokenFormConformsToForm() {
        let form: any Form = MockRefreshTokenForm(refreshToken: "token123")
        #expect(form is MockRefreshTokenForm)
    }

    @Test("RefreshTokenForm has refreshToken property")
    func refreshTokenFormHasToken() {
        let form = MockRefreshTokenForm(refreshToken: "my_refresh_token")
        #expect(form.refreshToken == "my_refresh_token")
    }

    // MARK: - LogoutForm Tests

    struct MockLogoutForm: LogoutForm {
        static func validations(_ validations: inout Validations) {
            // No validations needed for logout
        }
    }

    @Test("LogoutForm conforms to Form protocol")
    func logoutFormConformsToForm() {
        let form: any Form = MockLogoutForm()
        #expect(form is MockLogoutForm)
    }

    // MARK: - VerificationForm Tests

    struct MockEmailVerificationForm: EmailVerificationForm {
        static func validations(_ validations: inout Validations) {
            validations.add("code", as: String.self, is: .count(6...20))
        }

        let code: String
    }

    struct MockPhoneVerificationForm: PhoneVerificationForm {
        static func validations(_ validations: inout Validations) {
            validations.add("code", as: String.self, is: .count(6...20))
        }

        let code: String
    }

    @Test("EmailVerificationForm conforms to VerificationForm")
    func emailVerificationFormConformsToVerificationForm() {
        let form: any VerificationForm = MockEmailVerificationForm(code: "123456")
        #expect(form is MockEmailVerificationForm)
    }

    @Test("PhoneVerificationForm conforms to VerificationForm")
    func phoneVerificationFormConformsToVerificationForm() {
        let form: any VerificationForm = MockPhoneVerificationForm(code: "123456")
        #expect(form is MockPhoneVerificationForm)
    }

    @Test("VerificationForm has code property")
    func verificationFormHasCode() {
        let form = MockEmailVerificationForm(code: "ABC123")
        #expect(form.code == "ABC123")
    }

    // MARK: - Email Password Reset Forms Tests

    struct MockEmailPasswordResetRequestForm: EmailPasswordResetRequestForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
        }

        let email: String
    }

    struct MockEmailPasswordResetVerifyForm: EmailPasswordResetVerifyForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
            validations.add("code", as: String.self, is: .count(6...20))
            validations.add("newPassword", as: String.self, is: .count(6...))
        }

        let email: String
        let code: String
        let newPassword: String
    }

    struct MockEmailPasswordResetResendForm: EmailPasswordResetResendForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
        }

        let email: String
    }

    @Test("EmailPasswordResetRequestForm conforms to Form")
    func emailPasswordResetRequestFormConformsToForm() {
        let form: any Form = MockEmailPasswordResetRequestForm(email: "test@example.com")
        #expect(form is MockEmailPasswordResetRequestForm)
    }

    @Test("EmailPasswordResetVerifyForm has required properties")
    func emailPasswordResetVerifyFormProperties() {
        let form = MockEmailPasswordResetVerifyForm(
            email: "test@example.com",
            code: "123456",
            newPassword: "newpassword123"
        )

        #expect(form.email == "test@example.com")
        #expect(form.code == "123456")
        #expect(form.newPassword == "newpassword123")
    }

    @Test("EmailPasswordResetResendForm has email property")
    func emailPasswordResetResendFormEmail() {
        let form = MockEmailPasswordResetResendForm(email: "test@example.com")
        #expect(form.email == "test@example.com")
    }

    // MARK: - Phone Password Reset Forms Tests

    struct MockPhonePasswordResetRequestForm: PhonePasswordResetRequestForm {
        static func validations(_ validations: inout Validations) {
            validations.add("phone", as: String.self, is: .count(6...))
        }

        let phone: String
    }

    struct MockPhonePasswordResetVerifyForm: PhonePasswordResetVerifyForm {
        static func validations(_ validations: inout Validations) {
            validations.add("phone", as: String.self, is: .count(6...))
            validations.add("code", as: String.self, is: .count(6...20))
            validations.add("newPassword", as: String.self, is: .count(6...))
        }

        let phone: String
        let code: String
        let newPassword: String
    }

    struct MockPhonePasswordResetResendForm: PhonePasswordResetResendForm {
        static func validations(_ validations: inout Validations) {
            validations.add("phone", as: String.self, is: .count(6...))
        }

        let phone: String
    }

    @Test("PhonePasswordResetRequestForm conforms to Form")
    func phonePasswordResetRequestFormConformsToForm() {
        let form: any Form = MockPhonePasswordResetRequestForm(phone: "+1234567890")
        #expect(form is MockPhonePasswordResetRequestForm)
    }

    @Test("PhonePasswordResetVerifyForm has required properties")
    func phonePasswordResetVerifyFormProperties() {
        let form = MockPhonePasswordResetVerifyForm(
            phone: "+1234567890",
            code: "123456",
            newPassword: "newpassword123"
        )

        #expect(form.phone == "+1234567890")
        #expect(form.code == "123456")
        #expect(form.newPassword == "newpassword123")
    }

    @Test("PhonePasswordResetResendForm has phone property")
    func phonePasswordResetResendFormPhone() {
        let form = MockPhonePasswordResetResendForm(phone: "+1234567890")
        #expect(form.phone == "+1234567890")
    }

    // MARK: - Protocol Hierarchy Tests

    @Test("All form protocols inherit from Form")
    func allFormProtocolsInheritFromForm() {
        let forms: [any Form] = [
            MockRefreshTokenForm(refreshToken: "token"),
            MockLogoutForm(),
            MockEmailVerificationForm(code: "123456"),
            MockEmailPasswordResetRequestForm(email: "test@example.com"),
            MockPhonePasswordResetRequestForm(phone: "+1234567890")
        ]

        #expect(forms.count == 5)
        for form in forms {
            #expect(form is Content)
            #expect(form is Validatable)
        }
    }
}
