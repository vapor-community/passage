# Passage
[![Release](https://img.shields.io/github/v/release/vapor-community/passage)](https://github.com/vapor-community/passage/releases)
[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![License](https://img.shields.io/github/license/vapor-community/passage)](LICENSE)
[![codecov](https://codecov.io/gh/vapor-community/passage/branch/main/graph/badge.svg)](https://codecov.io/gh/vapor-community/passage)

A comprehensive identity management and authentication framework for Vapor applications built with Swift. Passage provides secure authentication with minimal configuration while remaining highly extensible through protocol-based architecture. **Not yet production-ready.**

## Status: Developer Preview

## Features

- 🔐 **User Registration & Login** - Complete authentication flow with secure password hashing
- 📧 **Email Authentication** - Email-based identifier with verification codes
- 📱 **Phone Authentication** - Phone number identifier with SMS verification (requires custom implementation of `PhoneDelivery` service)
- 👤 **Username & Password** - Traditional username/password authentication
- ✨ **Passwordless Magic Links** - Email-based passwordless authentication with one-click login
- 🎫 **JWT Access Tokens** - Stateless authentication with JWKS support
- 🔄 **Refresh Token Rotation** - Secure token refresh with family-based revocation
- 🔑 **Password Reset Flow** - Email and phone-based password recovery
- 🌐 **OAuth Integration** - Federated login (Google, GitHub, custom providers)
- 🔗 **Account Linking** - Link multiple identifiers to a single user account (automatic or manual)
- 📋 **Web Forms** - Built-in Leaf templates for registration, login, and password reset
- ⚡ **Async Queue Support** - Optional background job processing via Vapor Queues
- 🔧 **Protocol-Based Services** - Pluggable storage, email, phone, and OAuth providers
- 🎨 **Fully Customizable** - Configure routes, tokens, templates, and behavior

## Getting Started

### Installation

Add Passage to your `Package.swift`:

```swift
dependencies: [
    // 🛂 Authentication and user management for Vapor.
    .package(url: "https://github.com/vapor-community/passage", branch: "main"),
]
```

Then add `"Passage"` to your target dependencies:

```swift                
.product(name: "Passage", package: "passage"),
```

Add `PassageOnlyForTest` **only** if you want to use the in-memory store for testing:

```swift
.product(name: "PassageOnlyForTest", package: "passage"),
```

### Basic Setup
1. Set a custom working directory in your scheme and point it to your project folder.
2. Create a JWKS file `keypair.jwks` and place it in the root of your project.
3. Configure Passage in your `configure.swift`:

```swift
// enable Leaf templating to use Passage's built-in views
app.views.use(.leaf)

// enable sessions middleware
app.middleware.use(app.sessions.middleware)

// Configure Passage with in-memory store for testing
try await app.passage.configure(
    services: .init(
        store: Passage.OnlyForTest.InMemoryStore(),
        emailDelivery: nil,
        phoneDelivery: nil,
    ),
    configuration: .init(
        origin: URL(string: "http://localhost:8080")!,
        sessions: .init(enabled: true),
        jwt: .init(
            jwks: .file(path: "\(app.directory.workingDirectory)keypair.jwks")
        ),
        views: .init(
            register: .init(
                style: .minimalism,
                theme: .init(
                    colors: .mintDark
                ),
                identifier: .username
            ),
            login: .init(
                style: .minimalism,
                theme: .init(
                    colors: .mintDark
                ),
                identifier: .username
            )
        )
    )
)
```

### Example Usage
In your `routes.swift` file, protect routes using Passage's authenticators and guards:

```swift
app
    .grouped(PassageSessionAuthenticator())
    .grouped(PassageBearerAuthenticator())
    .grouped(PassageGuard())
    .get("protected") { req async throws -> String in
        let user = try req.passage.user
        return "Hello, \(String(describing: user.id))!"
}
```

This adds two view endpoints at `http://localhost:8080/auth/register` and `http://localhost:8080/auth/login` for user registration and login, as well as a protected route at `http://localhost:8080/protected` that requires authentication.

## Customization

Passage is designed for flexibility through:

- **Comprehensive Configuration** - Customize routes, token TTLs, JWT settings, verification flows, OAuth providers, and web forms
- **Protocol-Based Services** - Implement your own storage, email delivery, phone delivery, or OAuth providers
- **Extensible Forms** - Default form types can be replaced with custom implementations via contracts
- **Stylable Default Views** - Default Leaf views with different styles and themes

## Services to Implement

### Store (Required)

The `Store` protocol is the **only required service** you must provide. It handles all persistence for users, identifiers, tokens, and verification codes.

**Recommended Implementation**: Use the [passage-fluent](https://github.com/rozd/passage-fluent) package, which provides a complete Fluent-based storage implementation with migrations for PostgreSQL, MySQL, and SQLite.

**Testing Implementation**: The `PassageOnlyForTest` module provides an in-memory store for testing purposes.

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

**Recommended Implementation**: Use the [passage-mailgun](https://github.com/rozd/passage-mailgun) package for Mailgun integration.

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

Or implement your own email provider by conforming to the `Passage.EmailDelivery` protocol.

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

**Recommended Implementation**: Use the [passage-imperial](https://github.com/rozd/passage-imperial) package, which integrates with the Imperial OAuth library.

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
        federatedLogin: .init(
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
            issuer: "https://api.example.com",
            accessToken: .init(
                timeToLive: 900          // 15 minutes
            ),
            refreshToken: .init(
                timeToLive: 2_592_000    // 30 days
            ),
        ),

        // JWT/JWKS configuration
        jwt: .init(
            jwks: try .fileFromEnvironment(),  // Load from JWKS env var or file
        ),
        
        // Passwordless authentication (magic links)
        passwordless: .init(
            emailMagicLink: .email(
                autoCreateUser: true,
                requireSameBrowser: true
            )
        ),

        // Email/Phone verification settings; providing an `EmailDelivery` or `PhoneDelivery` service enables verification
        verification: .init(
            email: .init(
                codeLength: 6,
                codeExpiration: 600,
                maxAttempts: 5
            ),
            phone: .init(
                                codeLength: 6,
                codeExpiration: 600,
                maxAttempts: 5
            ),
            useQueues: true  // Global queue setting
        ),

        // Password reset settings; as with verification, providing `EmailDelivery` or `PhoneDelivery` enables password reset
        restoration: .init(
            preferredDelivery: .email,
            email: .init(
                codeLength: 6,
                codeExpiration: 600,
                maxAttempts: 5
            )
            useQueues: true
        ),

        // Federated Login configuration
        federatedLogin: .init(
            providers: [
                .github(
                    credentials: .conventional
                ),
                .google(
                    credentials: .conventional,
                    scope: ["profile", "email"]
                )
            ],
            accountLinking: .init(
                strategy: .automatic(
                    allowed: [.email, .phone],
                    // Links accounts automatically by matching identifiers;
                    // falls back to manual linking when multiple matches exist
                    fallbackToManualOnMultipleMatches: true
                )
            )
        ),

        // Web form views (Leaf templates)
        views: .init(
            register: .init(/* ... */),
            login: .init(/* ... */),
            passwordResetRequest: .init(/* ... */)
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
