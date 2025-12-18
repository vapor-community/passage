# Errors

Error types thrown by Passage operations.

All errors conform to Vapor's `AbortError` for automatic HTTP status code mapping.

## Types

| Type | Description |
|------|-------------|
| `PassageError` | Configuration and system errors |
| `AuthenticationError` | Authentication flow errors |

## PassageError Cases

| Case | Status | Description |
|------|--------|-------------|
| `notConfigured` | 500 | Passage not configured |
| `storeNotConfigured` | 500 | Store not provided |
| `jwksNotConfigured` | 500 | JWKS not configured |
| `emailDeliveryNotConfigured` | 500 | Email delivery not provided |
| `phoneDeliveryNotConfigured` | 500 | Phone delivery not provided |
| `emailMagicLinkNotConfigured` | 500 | Magic link not configured |
| `missingEnvironmentVariable` | 500 | Required env var missing |
| `unexpected` | 500 | Unexpected error with message |

## AuthenticationError Cases

**Registration:**
- `identifierNotSpecified` (400), `emailAlreadyRegistered` (409), `phoneAlreadyRegistered` (409), `usernameAlreadyRegistered` (409), `passwordsDoNotMatch` (400)

**Login:**
- `invalidEmailOrPassword` (401), `invalidPhoneOrPassword` (401), `invalidUsernameOrPassword` (401), `emailIsNotVerified` (403), `phoneIsNotVerified` (403), `passwordIsNotSet` (500)

**Tokens:**
- `invalidRefreshToken` (401), `refreshTokenExpired` (401), `refreshTokenNotFound` (404)

**Verification:**
- `emailNotSet` (400), `emailAlreadyVerified` (409), `phoneNotSet` (400), `phoneAlreadyVerified` (409), `invalidVerificationCode` (401), `verificationCodeExpiredOrMaxAttempts` (410)

**Restoration:**
- `restorationCodeInvalid` (401), `restorationCodeExpired` (410), `restorationCodeMaxAttempts` (410), `restorationIdentifierNotFound` (404), `restorationDeliveryNotAvailable` (503)

**Magic Link:**
- `magicLinkInvalid` (401), `magicLinkExpired` (410), `magicLinkMaxAttempts` (410), `magicLinkEmailNotFound` (404), `magicLinkDifferentBrowser` (403)

**Federated:**
- `federatedAccountAlreadyLinked` (409), `federatedLoginFailed` (401), `userNotFound` (404)
