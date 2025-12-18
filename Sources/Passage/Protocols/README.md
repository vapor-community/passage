# Protocols

Core protocols that storage implementations must conform to.

## Types

| Protocol | Description |
|----------|-------------|
| `User` | Application user with identifiers and password hash |
| `UserInfo` | Minimal user info (email, phone) |
| `RefreshToken` | Opaque refresh token with rotation support |
| `ExchangeToken` | Short-lived OAuth exchange code |
| `VerificationCode` | Base protocol for verification codes |
| `EmailVerificationCode` | Email verification code |
| `PhoneVerificationCode` | Phone verification code |
| `RestorationCode` | Base protocol for password reset codes |
| `EmailPasswordResetCode` | Email password reset code |
| `PhonePasswordResetCode` | Phone password reset code |
| `MagicLinkToken` | Passwordless magic link token |

## User Protocol

```swift
protocol User: Authenticatable, SessionAuthenticatable, Sendable {
    var id: Id? { get }
    var email: String? { get }
    var phone: String? { get }
    var username: String? { get }
    var passwordHash: String? { get }
    var isAnonymous: Bool { get }
    var isEmailVerified: Bool { get }
    var isPhoneVerified: Bool { get }
}
```

## Token Protocols

| Protocol | Key Properties |
|----------|----------------|
| `RefreshToken` | `tokenHash`, `expiresAt`, `revokedAt`, `replacedBy`, `user` |
| `ExchangeToken` | `tokenHash`, `expiresAt`, `consumedAt`, `user` |
| `MagicLinkToken` | `tokenHash`, `sessionTokenHash`, `expiresAt`, `failedAttempts`, `identifier` |

## Code Protocols

| Protocol | Key Properties |
|----------|----------------|
| `VerificationCode` | `codeHash`, `expiresAt`, `failedAttempts`, `user` |
| `RestorationCode` | `codeHash`, `expiresAt`, `failedAttempts`, `user` |
