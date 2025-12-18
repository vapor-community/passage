# Types

Value types and domain objects.

## Types

| Type | Description |
|------|-------------|
| `AccessToken` | JWT access token payload with standard claims |
| `IdToken` | JWT ID token with user info claims (future use) |
| `Identifier` | User identifier (email, phone, username, or federated) |
| `Credential` | User credential (password hash) |
| `FederatedProvider` | OAuth provider configuration |
| `FederatedIdentity` | OAuth identity with verified emails/phones |
| `LinkingResolution` | Account linking strategy (disabled, automatic, manual) |

## AccessToken

JWT payload with claims: `sub`, `exp`, `iat`, `iss`, `aud`, `scope`

## Identifier

```swift
struct Identifier {
    let kind: Kind      // .email, .phone, .username, .federated
    let value: String
    let provider: FederatedProvider.Name?  // Only for federated
}
```

Static constructors: `.email(_:)`, `.phone(_:)`, `.username(_:)`, `.federated(_:userId:)`

## FederatedProvider

```swift
struct FederatedProvider {
    let name: Name           // e.g., .google, .github
    let credentials: Credentials  // .conventional or .client(id:secret:)
    let scope: [String]
}
```

Static constructors: `.google()`, `.github()`, `.custom(name:)`

## FederatedIdentity

OAuth identity returned from provider callback:

```swift
struct FederatedIdentity {
    let identifier: Identifier
    let provider: FederatedProvider.Name
    let verifiedEmails: [String]
    let verifiedPhoneNumbers: [String]
    let displayName: String?
    let profilePictureURL: String?
}
```

## LinkingResolution

```swift
enum LinkingResolution {
    case disabled
    case automatic(matchBy: [Identifier.Kind], onAmbiguity: AmbiguityResolution)
    case manual(matchBy: [Identifier.Kind])
}
```
