import Testing
import Vapor
@testable import Passage

@Suite("Default Forms Tests")
struct DefaultFormsTests {

    // MARK: - DefaultLoginForm Tests

    @Test("DefaultLoginForm initialization")
    func defaultLoginFormInitialization() {
        let form = Passage.DefaultLoginForm(
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

    @Test("DefaultLoginForm conforms to LoginForm")
    func defaultLoginFormConformsToLoginForm() {
        let form: any LoginForm = Passage.DefaultLoginForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123"
        )
        #expect(form is Passage.DefaultLoginForm)
    }

    @Test("DefaultLoginForm validate does not throw")
    func defaultLoginFormValidateDoesNotThrow() throws {
        let form = Passage.DefaultLoginForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123"
        )
        try form.validate() // Should not throw
    }

    // MARK: - DefaultRegisterForm Tests

    @Test("DefaultRegisterForm initialization")
    func defaultRegisterFormInitialization() {
        let form = Passage.DefaultRegisterForm(
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

    @Test("DefaultRegisterForm conforms to RegisterForm")
    func defaultRegisterFormConformsToRegisterForm() {
        let form: any RegisterForm = Passage.DefaultRegisterForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )
        #expect(form is Passage.DefaultRegisterForm)
    }

    @Test("DefaultRegisterForm validate succeeds when passwords match")
    func defaultRegisterFormValidateSucceeds() throws {
        let form = Passage.DefaultRegisterForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "password123"
        )
        try form.validate() // Should not throw
    }

    @Test("DefaultRegisterForm validate throws when passwords don't match")
    func defaultRegisterFormValidateThrows() {
        let form = Passage.DefaultRegisterForm(
            email: "test@example.com",
            phone: nil,
            username: nil,
            password: "password123",
            confirmPassword: "different_password"
        )

        #expect(throws: AuthenticationError.passwordsDoNotMatch) {
            try form.validate()
        }
    }

    // MARK: - DefaultRefreshTokenForm Tests

    @Test("DefaultRefreshTokenForm initialization")
    func defaultRefreshTokenFormInitialization() {
        let form = Passage.DefaultRefreshTokenForm(refreshToken: "my_token")
        #expect(form.refreshToken == "my_token")
    }

    @Test("DefaultRefreshTokenForm conforms to RefreshTokenForm")
    func defaultRefreshTokenFormConformsToRefreshTokenForm() {
        let form: any RefreshTokenForm = Passage.DefaultRefreshTokenForm(refreshToken: "my_token")
        #expect(form is Passage.DefaultRefreshTokenForm)
    }

    @Test("DefaultRefreshTokenForm validate does not throw")
    func defaultRefreshTokenFormValidateDoesNotThrow() throws {
        let form = Passage.DefaultRefreshTokenForm(refreshToken: "my_token")
        try form.validate() // Should not throw
    }

    // MARK: - DefaultLogoutForm Tests

    @Test("DefaultLogoutForm initialization")
    func defaultLogoutFormInitialization() {
        let form = Passage.DefaultLogoutForm()
        let _: any LogoutForm = form
        #expect(form is Passage.DefaultLogoutForm)
    }

    @Test("DefaultLogoutForm conforms to LogoutForm")
    func defaultLogoutFormConformsToLogoutForm() {
        let form: any LogoutForm = Passage.DefaultLogoutForm()
        #expect(form is Passage.DefaultLogoutForm)
    }

    // MARK: - DefaultEmailVerificationForm Tests

    @Test("DefaultEmailVerificationForm initialization")
    func defaultEmailVerificationFormInitialization() {
        let form = Passage.DefaultEmailVerificationForm(code: "123456")
        #expect(form.code == "123456")
    }

    @Test("DefaultEmailVerificationForm conforms to EmailVerificationForm")
    func defaultEmailVerificationFormConformsToEmailVerificationForm() {
        let form: any EmailVerificationForm = Passage.DefaultEmailVerificationForm(code: "123456")
        #expect(form is Passage.DefaultEmailVerificationForm)
    }

    // MARK: - DefaultPhoneVerificationForm Tests

    @Test("DefaultPhoneVerificationForm initialization")
    func defaultPhoneVerificationFormInitialization() {
        let form = Passage.DefaultPhoneVerificationForm(code: "123456")
        #expect(form.code == "123456")
    }

    @Test("DefaultPhoneVerificationForm conforms to PhoneVerificationForm")
    func defaultPhoneVerificationFormConformsToPhoneVerificationForm() {
        let form: any PhoneVerificationForm = Passage.DefaultPhoneVerificationForm(code: "123456")
        #expect(form is Passage.DefaultPhoneVerificationForm)
    }

    // MARK: - DefaultEmailPasswordResetRequestForm Tests

    @Test("DefaultEmailPasswordResetRequestForm initialization")
    func defaultEmailPasswordResetRequestFormInitialization() {
        let form = Passage.DefaultEmailPasswordResetRequestForm(email: "test@example.com")
        #expect(form.email == "test@example.com")
    }

    @Test("DefaultEmailPasswordResetRequestForm conforms to protocol")
    func defaultEmailPasswordResetRequestFormConformsToProtocol() {
        let form: any EmailPasswordResetRequestForm = Passage.DefaultEmailPasswordResetRequestForm(email: "test@example.com")
        #expect(form is Passage.DefaultEmailPasswordResetRequestForm)
    }

    // MARK: - DefaultEmailPasswordResetVerifyForm Tests

    @Test("DefaultEmailPasswordResetVerifyForm initialization")
    func defaultEmailPasswordResetVerifyFormInitialization() {
        let form = Passage.DefaultEmailPasswordResetVerifyForm(
            email: "test@example.com",
            code: "123456",
            newPassword: "newpassword123"
        )

        #expect(form.email == "test@example.com")
        #expect(form.code == "123456")
        #expect(form.newPassword == "newpassword123")
    }

    @Test("DefaultEmailPasswordResetVerifyForm conforms to protocol")
    func defaultEmailPasswordResetVerifyFormConformsToProtocol() {
        let form: any EmailPasswordResetVerifyForm = Passage.DefaultEmailPasswordResetVerifyForm(
            email: "test@example.com",
            code: "123456",
            newPassword: "newpassword123"
        )
        #expect(form is Passage.DefaultEmailPasswordResetVerifyForm)
    }

    // MARK: - DefaultEmailPasswordResetResendForm Tests

    @Test("DefaultEmailPasswordResetResendForm initialization")
    func defaultEmailPasswordResetResendFormInitialization() {
        let form = Passage.DefaultEmailPasswordResetResendForm(email: "test@example.com")
        #expect(form.email == "test@example.com")
    }

    @Test("DefaultEmailPasswordResetResendForm conforms to protocol")
    func defaultEmailPasswordResetResendFormConformsToProtocol() {
        let form: any EmailPasswordResetResendForm = Passage.DefaultEmailPasswordResetResendForm(email: "test@example.com")
        #expect(form is Passage.DefaultEmailPasswordResetResendForm)
    }

    // MARK: - DefaultPhonePasswordResetRequestForm Tests

    @Test("DefaultPhonePasswordResetRequestForm initialization")
    func defaultPhonePasswordResetRequestFormInitialization() {
        let form = Passage.DefaultPhonePasswordResetRequestForm(phone: "+1234567890")
        #expect(form.phone == "+1234567890")
    }

    @Test("DefaultPhonePasswordResetRequestForm conforms to protocol")
    func defaultPhonePasswordResetRequestFormConformsToProtocol() {
        let form: any PhonePasswordResetRequestForm = Passage.DefaultPhonePasswordResetRequestForm(phone: "+1234567890")
        #expect(form is Passage.DefaultPhonePasswordResetRequestForm)
    }

    // MARK: - DefaultPhonePasswordResetVerifyForm Tests

    @Test("DefaultPhonePasswordResetVerifyForm initialization")
    func defaultPhonePasswordResetVerifyFormInitialization() {
        let form = Passage.DefaultPhonePasswordResetVerifyForm(
            phone: "+1234567890",
            code: "123456",
            newPassword: "newpassword123"
        )

        #expect(form.phone == "+1234567890")
        #expect(form.code == "123456")
        #expect(form.newPassword == "newpassword123")
    }

    @Test("DefaultPhonePasswordResetVerifyForm conforms to protocol")
    func defaultPhonePasswordResetVerifyFormConformsToProtocol() {
        let form: any PhonePasswordResetVerifyForm = Passage.DefaultPhonePasswordResetVerifyForm(
            phone: "+1234567890",
            code: "123456",
            newPassword: "newpassword123"
        )
        #expect(form is Passage.DefaultPhonePasswordResetVerifyForm)
    }

    // MARK: - DefaultPhonePasswordResetResendForm Tests

    @Test("DefaultPhonePasswordResetResendForm initialization")
    func defaultPhonePasswordResetResendFormInitialization() {
        let form = Passage.DefaultPhonePasswordResetResendForm(phone: "+1234567890")
        #expect(form.phone == "+1234567890")
    }

    @Test("DefaultPhonePasswordResetResendForm conforms to protocol")
    func defaultPhonePasswordResetResendFormConformsToProtocol() {
        let form: any PhonePasswordResetResendForm = Passage.DefaultPhonePasswordResetResendForm(phone: "+1234567890")
        #expect(form is Passage.DefaultPhonePasswordResetResendForm)
    }

    // MARK: - All Default Forms Tests

    @Test("All default forms conform to Content")
    func allDefaultFormsConformToContent() {
        let forms: [any Content] = [
            Passage.DefaultLoginForm(email: "test@example.com", phone: nil, username: nil, password: "password123"),
            Passage.DefaultRegisterForm(email: "test@example.com", phone: nil, username: nil, password: "password123", confirmPassword: "password123"),
            Passage.DefaultRefreshTokenForm(refreshToken: "token"),
            Passage.DefaultLogoutForm(),
            Passage.DefaultEmailVerificationForm(code: "123456"),
            Passage.DefaultPhoneVerificationForm(code: "123456"),
            Passage.DefaultEmailPasswordResetRequestForm(email: "test@example.com"),
            Passage.DefaultPhonePasswordResetRequestForm(phone: "+1234567890")
        ]

        #expect(forms.count == 8)
    }
}
