//

public extension Passage {

    struct Contracts: Sendable {
        let loginForm: any LoginForm.Type
        let logoutForm: any LogoutForm.Type
        let registerForm: any RegisterForm.Type
        let refreshTokenForm: any RefreshTokenForm.Type
        let emailVerificationForm: any EmailVerificationForm.Type
        let phoneVerificationForm: any PhoneVerificationForm.Type
        let emailPasswordResetRequestForm: any EmailPasswordResetRequestForm.Type
        let emailPasswordResetVerifyForm: any EmailPasswordResetVerifyForm.Type
        let emailPasswordResetResendForm: any EmailPasswordResetResendForm.Type
        let phonePasswordResetRequestForm: any PhonePasswordResetRequestForm.Type
        let phonePasswordResetVerifyForm: any PhonePasswordResetVerifyForm.Type
        let phonePasswordResetResendForm: any PhonePasswordResetResendForm.Type
        let emailMagicLinkRequestForm: any EmailMagicLinkRequestForm.Type
        let emailMagicLinkVerifyForm: any EmailMagicLinkVerifyForm.Type
        let emailMagicLinkResendForm: any EmailMagicLinkResendForm.Type

        public init(
            loginForm: (any LoginForm.Type)? = nil,
            logoutForm: (any LogoutForm.Type)? = nil,
            registerForm: (any RegisterForm.Type)? = nil,
            refreshTokenForm: (any RefreshTokenForm.Type)? = nil,
            emailVerificationForm: (any EmailVerificationForm.Type)? = nil,
            phoneVerificationForm: (any PhoneVerificationForm.Type)? = nil,
            emailPasswordResetRequestForm: (any EmailPasswordResetRequestForm.Type)? = nil,
            emailPasswordResetVerifyForm: (any EmailPasswordResetVerifyForm.Type)? = nil,
            emailPasswordResetResendForm: (any EmailPasswordResetResendForm.Type)? = nil,
            phonePasswordResetRequestForm: (any PhonePasswordResetRequestForm.Type)? = nil,
            phonePasswordResetVerifyForm: (any PhonePasswordResetVerifyForm.Type)? = nil,
            phonePasswordResetResendForm: (any PhonePasswordResetResendForm.Type)? = nil,
            emailMagicLinkRequestForm: (any EmailMagicLinkRequestForm.Type)? = nil,
            emailMagicLinkVerifyForm: (any EmailMagicLinkVerifyForm.Type)? = nil,
            emailMagicLinkResendForm: (any EmailMagicLinkResendForm.Type)? = nil,

        ) {
            self.loginForm = loginForm ?? DefaultLoginForm.self
            self.logoutForm = logoutForm ?? DefaultLogoutForm.self
            self.registerForm = registerForm ?? DefaultRegisterForm.self
            self.refreshTokenForm = refreshTokenForm ?? DefaultRefreshTokenForm.self
            self.emailVerificationForm = emailVerificationForm ?? DefaultEmailVerificationForm.self
            self.phoneVerificationForm = phoneVerificationForm ?? DefaultPhoneVerificationForm.self
            self.emailPasswordResetRequestForm = emailPasswordResetRequestForm ?? DefaultEmailPasswordResetRequestForm.self
            self.emailPasswordResetVerifyForm = emailPasswordResetVerifyForm ?? DefaultEmailPasswordResetVerifyForm.self
            self.emailPasswordResetResendForm = emailPasswordResetResendForm ?? DefaultEmailPasswordResetResendForm.self
            self.phonePasswordResetRequestForm = phonePasswordResetRequestForm ?? DefaultPhonePasswordResetRequestForm.self
            self.phonePasswordResetVerifyForm = phonePasswordResetVerifyForm ?? DefaultPhonePasswordResetVerifyForm.self
            self.phonePasswordResetResendForm = phonePasswordResetResendForm ?? DefaultPhonePasswordResetResendForm.self
            self.emailMagicLinkRequestForm = emailMagicLinkRequestForm ?? DefaultEmailMagicLinkRequestForm.self
            self.emailMagicLinkVerifyForm = emailMagicLinkVerifyForm ?? DefaultEmailMagicLinkVerifyForm.self
            self.emailMagicLinkResendForm = emailMagicLinkResendForm ?? DefaultEmailMagicLinkResendForm.self
        }
    }

}
