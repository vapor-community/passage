# Passage

A comprehensive identity management and authentication framework for Vapor applications built with Swift. Passage provides secure, production-ready authentication with minimal configuration while remaining highly extensible through protocol-based architecture.

## Status: Developer Preview

## Features

- 🔐 **User Registration & Login** - Complete authentication flow with secure password hashing
- 📧 **Email Authentication** - Email-based identifier with verification codes
- 📱 **Phone Authentication** - Phone number identifier with SMS verification
- 👤 **Username & Password** - Traditional username/password authentication
- ✨ **Passwordless Magic Links** - Email-based passwordless authentication with one-click login
- 🎫 **JWT Access Tokens** - Stateless authentication with JWKS support
- 🔄 **Refresh Token Rotation** - Secure token refresh with family-based revocation
- 🔑 **Password Reset Flow** - Email and phone-based password recovery
- 🌐 **OAuth Integration** - Federated login (Google, GitHub, custom providers)
- 📋 **Web Forms** - Built-in Leaf templates for registration, login, and password reset
- ⚡ **Async Queue Support** - Optional background job processing via Vapor Queues
- 🔧 **Protocol-Based Services** - Pluggable storage, email, phone, and OAuth providers
- 🎨 **Fully Customizable** - Configure routes, tokens, templates, and behavior

## Getting Started

### Installation

Add Passage to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/rozd/passage.git", from: "0.1.0"),
]
```

### Basic Setup

```swift
import Passage
import Vapor

// 1. Implement the User protocol on your user model
extension User: Passage.User {
    var id: UUID? { get set }
    var email: String? { get set }
    var passwordHash: String? { get set }
    // ... other required properties
}

// 2. Configure Passage in configure.swift
func configure(_ app: Application) async throws {
    // Initialize your storage implementation (e.g., Fluent)
    let store = DatabaseStore(db: app.db)

    // Configure Passage
    try await app.passage.configure(
        services: .init(
            store: store,
            emailDelivery: MyEmailService(),  // Optional
            phoneDelivery: MyPhoneService(),  // Optional
            federatedLogin: MyOAuthService()  // Optional
        ),
        configuration: .init(
            origin: URL(string: "https://api.example.com")!,
            routes: .init(group: "auth"),
            jwt: .init(jwks: try .fileFromEnvironment())
        )
    )
}
```

### Example Usage

```swift
// Register a new user
POST /auth/register
{
    "email": "user@example.com",
    "password": "secure_password"
}

// Login
POST /auth/login
{
    "email": "user@example.com",
    "password": "secure_password"
}
// Response: { "accessToken": "...", "refreshToken": "..." }

// Refresh token
POST /auth/refresh-token
{
    "refreshToken": "..."
}

// Get current user (requires JWT Bearer token)
GET /auth/me
Authorization: Bearer <accessToken>
```

## Customization

Passage is designed for flexibility through:

- **Comprehensive Configuration** - Customize routes, token TTLs, JWT settings, verification flows, OAuth providers, and web forms
- **Protocol-Based Services** - Implement your own storage, email delivery, phone delivery, or OAuth providers
- **Extensible Forms** - Default form types can be replaced with custom implementations via contracts
- **Template Customization** - Override email templates and Leaf views for complete UI control

## Services to Implement

### Store (Required)

The `Store` protocol is the **only required service** you must provide. It handles all persistence for users, identifiers, tokens, and verification codes.

**Recommended Implementation**: Use the [passage-fluent](https://github.com/rozd/passage-fluent) package which provides a complete Fluent-based storage implementation with migrations for PostgreSQL, MySQL, and SQLite.

```swift
import PassageFluent

let store = DatabaseStore(app: app, db: app.db)
```

Or implement your own by conforming to `Passage.Store`, which composes four sub-stores:
- `UserStore` - User account management
- `TokenStore` - Refresh token storage and rotation
- `CodeStore` - Email/phone verification codes
- `ResetCodeStore` - Password reset codes

### EmailDelivery (Optional)

The `EmailDelivery` protocol handles sending verification codes and password reset emails. Implement this to enable email-based features.

**Recommended Implementation**: Use the [passage-mailgun](https://github.com/rozd/passage-mailgun) package for Mailgun integration:

```swift
import PassageMailgun

let emailDelivery = MailgunEmailDelivery(
    app: app,
    configuration: .init(
        mailgun: .init(
            apiKey: "your-mailgun-api-key",
            defaultDomain: .init("mg.example.com", .us)
        ),
        sender: .init(
            email: "noreply@mg.example.com",
            name: "No Reply"
        ),
    )
)
```

Or implement your own email provider by conforming to `Passage.EmailDelivery` protocol.

### PhoneDelivery (Optional)

The `PhoneDelivery` protocol handles sending SMS verification codes and password reset messages. Implement this to enable phone-based authentication.

Example implementation using Twilio, AWS SNS, or other SMS providers:

```swift
struct TwilioPhoneDelivery: Passage.PhoneDelivery {
    func send(code: String, to phone: String, on request: Request) async throws {
        // Send SMS via your preferred provider
    }
}
```

### FederatedLoginService (Optional)

The `FederatedLoginService` protocol enables OAuth-based authentication with providers like Google, GitHub, Facebook, etc.

**Recommended Implementation**: Use the [passage-imperial](https://github.com/rozd/passage-imperial) package which integrates with the Imperial OAuth library:

```swift
import PassageImperial

try await app.passage.configure(
    services: .init(
        store: store,
        federatedLogin: ImperialFederatedLoginService(
            services: [
                .github          : GitHub.self,
                .named("google") : Google.self,
            ]
        )
    ),
    configuration: .init(
        origin: URL(string: "https://api.example.com")!,
        oauth: .init(
            routes: .init(),
            providers: [
                .github(
                    credentials: .conventional
                ),
                .google(
                    credentials: .conventional,
                    scope: ["profile", "email"]
                )
            ]
        )
    )
)
```

### RandomGenerator (Optional)

The `RandomGenerator` protocol generates secure verification codes and tokens. **A default implementation is provided** using Swift's `RandomNumberGenerator`, so you typically don't need to implement this yourself.

Implement a custom generator only if you need specific code formats or cryptographic requirements:

```swift
struct CustomRandomGenerator: Passage.RandomGenerator {
    func generateCode(length: Int) -> String {
        // Custom code generation logic
    }
}
```

## Configuration

Configure Passage behavior through the `Passage.Configuration` struct:

```swift
try await app.passage.configure(
    services: services,
    configuration: .init(
        // Base origin URL for your API
        origin: URL(string: "https://api.example.com")!,

        // Customize route paths
        routes: .init(
            group: "auth",              // Base path (default: "auth")
            register: .init(path: "register"),
            login: .init(path: "login"),
            logout: .init(path: "logout"),
            refreshToken: .init(path: "refresh-token"),
            currentUser: .init(path: "me")
        ),

        // Configure token lifetimes
        tokens: .init(
            accessTokenTTL: 900,        // 15 minutes
            refreshTokenTTL: 2_592_000  // 30 days
        ),

        // JWT/JWKS configuration
        jwt: .init(
            jwks: try .fileFromEnvironment(),  // Load from JWKS env var or file
            issuer: "https://api.example.com",
            audience: "https://api.example.com"
        ),

        // Email verification settings
        verification: .init(
            email: .init(
                enabled: true,
                codeTTL: 600,           // 10 minutes
                useQueues: true         // Send via background jobs
            ),
            phone: .init(
                enabled: true,
                codeTTL: 600,
                useQueues: true
            ),
            useQueues: true  // Global queue setting
        ),

        // Password reset settings
        restoration: .init(
            email: .init(
                enabled: true,
                codeTTL: 3600,          // 1 hour
                routes: .init(/* ... */)
            ),
            phone: .init(
                enabled: true,
                codeTTL: 3600,
                routes: .init(/* ... */)
            ),
            useQueues: true
        ),

        // Passwordless authentication (magic links)
        passwordless: .init(
            emailMagicLink: .email(
                linkExpiration: 900,    // 15 minutes
                maxAttempts: 5,
                autoCreateUser: true,   // Create user on first magic link verification
                requireSameBrowser: false,
                useQueues: true
            )
        ),

        // OAuth provider configuration
        oauth: .init(
            routes: .init(
                group: "oauth",
                callback: "callback"
            ),
            providers: [
                .google(clientID: "...", clientSecret: "..."),
                .github(clientID: "...", clientSecret: "...")
            ],
            redirectLocation: "/dashboard"  // Where to redirect after OAuth
        ),

        // Web form views (Leaf templates)
        views: .init(
            enabled: true,
            register: .init(/* ... */),
            login: .init(/* ... */),
            resetPassword: .init(/* ... */)
        )
    )
)
```

### Key Configuration Options

- **Routes**: Customize all endpoint paths (registration, login, logout, token refresh, user info, verification, password reset)
- **Tokens**: Set TTLs for access and refresh tokens
- **JWT/JWKS**: Configure issuer, audience, and load JWKS from environment or file
- **Verification**: Enable/disable email/phone verification, set code TTLs, enable async queue processing
- **Restoration**: Configure password reset flows for email/phone
- **Passwordless**: Configure magic link authentication with link expiration, auto-create users, and same-browser verification
- **OAuth**: Define providers and callback routes
- **Views**: Enable web forms with customizable Leaf templates

### JWKS Configuration

Load JWKS from environment variable or file:

```bash
# Option 1: Environment variable
export JWKS='{"keys":[...]}'

# Option 2: File path
export JWKS_FILE_PATH="/path/to/jwks.json"
```

```swift
jwt: .init(jwks: try .fileFromEnvironment())
```
