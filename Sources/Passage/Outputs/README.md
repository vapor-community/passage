# Outputs

Response types for API endpoints.

## Types

| Type | Description |
|------|-------------|
| `AuthUser` | Authentication response with tokens and user info |

## AuthUser

Returned from login, register, and token refresh endpoints:

```swift
struct AuthUser: Content {
    let accessToken: String      // JWT access token
    let refreshToken: String     // Opaque refresh token
    let tokenType: String        // "Bearer"
    let expiresIn: TimeInterval  // Access token TTL in seconds
    let user: User               // User info (id, email, phone)
}
```

### AuthUser.User

Nested user info structure:

```swift
struct User: Content, UserInfo {
    let id: String
    let email: String?
    let phone: String?
}
```
