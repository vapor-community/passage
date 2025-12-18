# Contracts

Form type contracts for customizing request/response decoding.

The `Contracts` struct holds references to form types used for decoding API requests. Override defaults to customize validation or add fields.

## Types

| Type | Description |
|------|-------------|
| `Contracts` | Container holding all form type references with defaults |

## Default Form Types

| Contract | Default | Purpose |
|----------|---------|---------|
| `loginForm` | `DefaultLoginForm` | Login request |
| `logoutForm` | `DefaultLogoutForm` | Logout request |
| `registerForm` | `DefaultRegisterForm` | Registration request |
| `refreshTokenForm` | `DefaultRefreshTokenForm` | Token refresh request |
| `exchangeCodeForm` | `DefaultExchangeCodeForm` | OAuth code exchange |
| `emailVerificationRequestForm` | `DefaultEmailVerificationRequestForm` | Request email verification |
| `emailVerificationConfirmForm` | `DefaultEmailVerificationConfirmForm` | Confirm email verification |
| `phoneVerificationRequestForm` | `DefaultPhoneVerificationRequestForm` | Request phone verification |
| `phoneVerificationConfirmForm` | `DefaultPhoneVerificationConfirmForm` | Confirm phone verification |
| `emailPasswordResetRequestForm` | `DefaultEmailPasswordResetRequestForm` | Request password reset (email) |
| `emailPasswordResetVerifyForm` | `DefaultEmailPasswordResetVerifyForm` | Verify password reset (email) |
| `emailPasswordResetResendForm` | `DefaultEmailPasswordResetResendForm` | Resend password reset (email) |
| `phonePasswordResetRequestForm` | `DefaultPhonePasswordResetRequestForm` | Request password reset (phone) |
| `phonePasswordResetVerifyForm` | `DefaultPhonePasswordResetVerifyForm` | Verify password reset (phone) |
| `phonePasswordResetResendForm` | `DefaultPhonePasswordResetResendForm` | Resend password reset (phone) |
| `emailMagicLinkRequestForm` | `DefaultEmailMagicLinkRequestForm` | Request magic link |
| `emailMagicLinkVerifyForm` | `DefaultEmailMagicLinkVerifyForm` | Verify magic link |
| `emailMagicLinkResendForm` | `DefaultEmailMagicLinkResendForm` | Resend magic link |
| `linkAccountSelectForm` | `DefaultLinkAccountSelectForm` | Select account to link |
| `linkAccountVerifyForm` | `DefaultLinkAccountVerifyForm` | Verify account linking |
