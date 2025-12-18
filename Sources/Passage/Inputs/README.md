# Inputs

Form protocols and default implementations for API request decoding.

All forms conform to the `Form` protocol (extends Vapor's `Content` + `Validatable`).

## Base Protocol

| Protocol | Description |
|----------|-------------|
| `Form` | Base protocol for all input forms with validation |

## Form Protocols

| Protocol | File | Purpose |
|----------|------|---------|
| `LoginForm` | `LoginForm.swift` | Login credentials (identifier + password) |
| `LogoutForm` | `LogoutForm.swift` | Logout request (refresh token) |
| `RegisterForm` | `RegisterForm.swift` | Registration (identifier + password) |
| `RefreshTokenForm` | `RefreshTokenForm.swift` | Token refresh (refresh token) |
| `ExchangeCodeForm` | `ExchangeCodeForm.swift` | OAuth code exchange |
| `EmailVerificationRequestForm` | `VerificationForms.swift` | Request email verification |
| `EmailVerificationConfirmForm` | `VerificationForms.swift` | Confirm email with code |
| `PhoneVerificationRequestForm` | `VerificationForms.swift` | Request phone verification |
| `PhoneVerificationConfirmForm` | `VerificationForms.swift` | Confirm phone with code |
| `EmailPasswordResetRequestForm` | `RestorationForms.swift` | Request password reset (email) |
| `EmailPasswordResetVerifyForm` | `RestorationForms.swift` | Verify reset code + new password |
| `EmailPasswordResetResendForm` | `RestorationForms.swift` | Resend reset code (email) |
| `PhonePasswordResetRequestForm` | `RestorationForms.swift` | Request password reset (phone) |
| `PhonePasswordResetVerifyForm` | `RestorationForms.swift` | Verify reset code + new password |
| `PhonePasswordResetResendForm` | `RestorationForms.swift` | Resend reset code (phone) |
| `EmailMagicLinkRequestForm` | `PasswordlessForms.swift` | Request magic link |
| `EmailMagicLinkVerifyForm` | `PasswordlessForms.swift` | Verify magic link token |
| `EmailMagicLinkResendForm` | `PasswordlessForms.swift` | Resend magic link |
| `LinkAccountSelectForm` | `LinkAccountSelectForm.swift` | Select account to link |
| `LinkAccountVerifyForm` | `LinkAccountVerifyForm.swift` | Verify account ownership |

## Other Files

| File | Description |
|------|-------------|
| `Passage+Forms.swift` | Form access via `Request.forms` |
