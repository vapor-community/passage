import Testing
import Vapor
import VaporTesting
import JWTKit
import XCTQueues
@testable import Passage
@testable import PassageOnlyForTest

@Suite("Passwordless Authentication Integration Tests", .tags(.integration, .passwordless))
struct PasswordlessIntegrationTests {

    // MARK: - Helpers

    /// Helper class to capture sent emails and SMS
    final class CapturedMessages: @unchecked Sendable {
        var emails: [Passage.OnlyForTest.MockEmailDelivery.EphemeralEmail] = []
        var sms: [Passage.OnlyForTest.MockPhoneDelivery.EphemeralSMS] = []
    }

    // MARK: - Configuration Helpers

    /// Configures a test Vapor application with Passage and passwordless support
    @Sendable private func configure(_ app: Application) async throws {
        try await configureWithCapture(app, captured: nil, codeExpiration: 600, autoCreateUser: true)
    }

    /// Configures a test Vapor application with Passage and optional message capture
    @Sendable private func configureWithCapture(
        _ app: Application,
        captured: CapturedMessages? = nil,
        codeExpiration: TimeInterval = 600,
        autoCreateUser: Bool = true
    ) async throws {
        // Add HMAC key directly for testing
        await app.jwt.keys.add(
            hmac: HMACKey(from: "test-secret-key-for-jwt-signing"),
            digestAlgorithm: .sha256,
            kid: JWKIdentifier(string: "test-key")
        )

        app.queues.use(.asyncTest)

        // Configure Passage with test services
        let store = Passage.OnlyForTest.InMemoryStore()

        let emailCallback: (@Sendable (Passage.OnlyForTest.MockEmailDelivery.EphemeralEmail) -> Void)? =
            captured != nil ? { @Sendable in captured!.emails.append($0) } : nil
        let phoneCallback: (@Sendable (Passage.OnlyForTest.MockPhoneDelivery.EphemeralSMS) -> Void)? =
            captured != nil ? { @Sendable in captured!.sms.append($0) } : nil

        let emailDelivery = Passage.OnlyForTest.MockEmailDelivery(callback: emailCallback)
        let phoneDelivery = Passage.OnlyForTest.MockPhoneDelivery(callback: phoneCallback)

        let services = Passage.Services(
            store: store,
            random: DefaultRandomGenerator(),
            emailDelivery: emailDelivery,
            phoneDelivery: phoneDelivery,
            federatedLogin: nil
        )

        let emptyJwks = """
        {"keys":[]}
        """

        // TODO: Add passwordless configuration when implemented
        // passwordless: .init(
        //     email: .init(codeLength: 6, codeExpiration: codeExpiration, maxAttempts: 3),
        //     phone: .init(codeLength: 6, codeExpiration: codeExpiration, maxAttempts: 3),
        //     autoCreateUser: autoCreateUser,
        //     useQueues: true
        // )
        let configuration = try Passage.Configuration(
            origin: URL(string: "http://localhost:8080")!,
            routes: .init(),
            tokens: .init(
                issuer: "test-issuer",
                accessToken: .init(timeToLive: 3600),
                refreshToken: .init(timeToLive: 86400)
            ),
            jwt: .init(jwks: .init(json: emptyJwks)),
            verification: .init(
                email: .init(codeLength: 6, codeExpiration: 600, maxAttempts: 5),
                phone: .init(codeLength: 6, codeExpiration: 600, maxAttempts: 5),
                useQueues: true
            ),
            restoration: .init(
                email: .init(codeLength: 6, codeExpiration: 600, maxAttempts: 3),
                phone: .init(codeLength: 6, codeExpiration: 600, maxAttempts: 3),
                useQueues: true
            )
        )

        // Store expected passwordless configuration for tests to reference
        // These will be used once Passwordless configuration is implemented
        _ = codeExpiration  // silence unused warning
        _ = autoCreateUser  // silence unused warning

        try await app.passage.configure(
            services: services,
            configuration: configuration
        )
    }

    /// Creates a test user directly in the store (for existing user tests)
    @Sendable private func createTestUser(
        app: Application,
        email: String? = nil,
        phone: String? = nil,
        password: String = "password123",
        isEmailVerified: Bool = false,
        isPhoneVerified: Bool = false
    ) async throws {
        let store = app.passage.storage.services.store
        let passwordHash = try await app.password.async.hash(password)

        let credential: Credential
        if let email = email {
            credential = .email(email: email, passwordHash: passwordHash)
        } else if let phone = phone {
            credential = .phone(phone: phone, passwordHash: passwordHash)
        } else {
            fatalError("Must provide email or phone")
        }

        try await store.users.create(with: credential)

        if isEmailVerified || isPhoneVerified {
            let user = try await store.users.find(byCredential: credential)
            #expect(user != nil)

            if isEmailVerified {
                try await store.users.markEmailVerified(for: user!)
            }
            if isPhoneVerified {
                try await store.users.markPhoneVerified(for: user!)
            }
        }
    }

    // MARK: - Email Magic Link Tests

    // MARK: Email MagicL ink Request Tests

    @Test("Request passwordless code via email succeeds for new user")
    func requestPasswordlessEmailNewUser() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            let email = "newuser@example.com"

            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            try await app.queues.queue.worker.run()

            #expect(captured.emails.count == 1)

            let sentEmail = try #require(captured.emails.first)
            #expect(sentEmail.to == email)
            #expect(sentEmail.type == .passwordless)
            #expect(sentEmail.passwordlessCode != nil)
        }
    }

    @Test("Request passwordless code via email succeeds for existing user")
    func requestPasswordlessEmailExistingUser() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            let email = "existing@example.com"

            // Create existing user
            try await createTestUser(app: app, email: email, isEmailVerified: true)

            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            try await app.queues.queue.worker.run()

            #expect(captured.emails.count == 1)

            let sentEmail = try #require(captured.emails.first)
            #expect(sentEmail.to == email)
            #expect(sentEmail.passwordlessCode != nil)
        }
    }

    @Test("Request passwordless code fails when auto-create disabled and user doesn't exist")
    func requestPasswordlessEmailFailsWhenAutoCreateDisabled() async throws {
        try await withApp(configure: { app in
            try await configureWithCapture(app, captured: nil, autoCreateUser: false)
        }) { app in
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": "nonexistent@example.com"])
            }, afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }

    @Test("Request passwordless code fails with invalid email format")
    func requestPasswordlessEmailFailsWithInvalidEmail() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": "invalid-email"])
            }, afterResponse: { res in
                #expect(res.status == .badRequest)
            })
        }
    }

    @Test("Request passwordless code fails with missing email")
    func requestPasswordlessEmailFailsWithMissingEmail() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode([:] as [String: String])
            }, afterResponse: { res in
                #expect(res.status == .badRequest)
            })
        }
    }

    @Test("Passwordless user has no password set by default")
    func passwordlessUserHasNoPassword() async throws {
        let captured = CapturedMessages()
        let email = "nopassword@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request and verify code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.emails.first?.passwordlessCode)

            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            })

            // Verify user has no password
            let store = app.passage.storage.services.store
            let user = try await store.users.find(byIdentifier: Identifier(kind: .email, value: email))
            #expect(user != nil)
            #expect(user?.passwordHash == nil)

            // Attempting password login should fail
            try await app.testing().test(.POST, "/auth/login", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "password": "anypassword"
                ])
            }, afterResponse: { res in
                // Should fail because user has no password
                #expect(res.status == .unauthorized)
            })
        }
    }

    // MARK: Email Magic Link Verify Tests

    @Test("Verify passwordless email code succeeds and returns tokens for new user")
    func verifyPasswordlessEmailNewUser() async throws {
        let captured = CapturedMessages()
        let email = "newuser@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Step 1: Request passwordless code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            try await app.queues.queue.worker.run()

            let code = try #require(captured.emails.first?.passwordlessCode)

            // Step 2: Verify code and get tokens
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                let authUser = try res.content.decode(AuthUser.self)
                #expect(authUser.user.email == email)
                #expect(!authUser.accessToken.isEmpty)
                #expect(!authUser.refreshToken.isEmpty)
                #expect(authUser.tokenType == "Bearer")
                #expect(authUser.expiresIn == 3600)
            })
        }
    }

    @Test("Verify passwordless email code succeeds for existing user")
    func verifyPasswordlessEmailExistingUser() async throws {
        let captured = CapturedMessages()
        let email = "existing@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Create existing user
            try await createTestUser(app: app, email: email, isEmailVerified: true)

            // Get user ID before passwordless login
            let store = app.passage.storage.services.store
            let existingUser = try await store.users.find(byIdentifier: Identifier(kind: .email, value: email))
            let existingUserId = try #require(existingUser?.id?.description)

            // Step 1: Request passwordless code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            try await app.queues.queue.worker.run()

            let code = try #require(captured.emails.first?.passwordlessCode)

            // Step 2: Verify code and get tokens
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                let authUser = try res.content.decode(AuthUser.self)
                // Should be the same user, not a new one
                #expect(authUser.user.id == existingUserId)
                #expect(authUser.user.email == email)
            })
        }
    }

    @Test("Verify passwordless email code marks email as verified")
    func verifyPasswordlessEmailMarksVerified() async throws {
        let captured = CapturedMessages()
        let email = "newuser@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request and verify code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.emails.first?.passwordlessCode)

            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
            })

            // Check user in store is marked as verified
            let store = app.passage.storage.services.store
            let user = try await store.users.find(byIdentifier: Identifier(kind: .email, value: email))
            #expect(user?.isEmailVerified == true)
        }
    }

    @Test("Verify passwordless email code fails with invalid code")
    func verifyPasswordlessEmailFailsWithInvalidCode() async throws {
        let captured = CapturedMessages()
        let email = "user@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()

            // Try with wrong code
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": "wrongcode"
                ])
            }, afterResponse: { res in
                #expect(res.status == .unauthorized)
            })
        }
    }

    @Test("Verify passwordless email code fails with expired code")
    func verifyPasswordlessEmailFailsWithExpiredCode() async throws {
        let captured = CapturedMessages()
        let email = "user@example.com"

        try await withApp(configure: { app in
            // Set code to expire immediately
            try await configureWithCapture(app, captured: captured, codeExpiration: -1)
        }) { app in
            // Request code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.emails.first?.passwordlessCode)

            // Try to verify expired code
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res in
                #expect(res.status == .gone)
            })
        }
    }

    @Test("Verify passwordless email code fails after max attempts exceeded")
    func verifyPasswordlessEmailFailsAfterMaxAttempts() async throws {
        let captured = CapturedMessages()
        let email = "user@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()

            // Try wrong code 3 times (max attempts)
            for _ in 1...3 {
                try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                    try req.content.encode([
                        "email": email,
                        "code": "wrongcode"
                    ])
                }, afterResponse: { res in
                    #expect(res.status == .unauthorized)
                })
            }

            // Now even correct code should fail
            let correctCode = try #require(captured.emails.first?.passwordlessCode)
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": correctCode
                ])
            }, afterResponse: { res in
                #expect(res.status == .tooManyRequests)
            })
        }
    }

    @Test("Verify passwordless email code invalidates code after successful use")
    func verifyPasswordlessEmailInvalidatesCodeAfterUse() async throws {
        let captured = CapturedMessages()
        let email = "user@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.emails.first?.passwordlessCode)

            // Use code successfully
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            // Try to reuse code - should fail
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res in
                #expect(res.status == .unauthorized)
            })
        }
    }

    // MARK: - Resend Email Magic Link Code Tests

    @Test("Resend passwordless email code invalidates old code")
    func resendPasswordlessEmailCodeInvalidatesOldCode() async throws {
        let captured = CapturedMessages()
        let email = "user@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request initial code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()
            let firstCode = try #require(captured.emails.first?.passwordlessCode)

            // Resend code
            try await app.testing().test(.POST, "/auth/magic-link/email/resend", beforeRequest: { req in
                try req.content.encode(["email": email])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            try await app.queues.queue.worker.run()

            #expect(captured.emails.count == 2)
            let secondCode = try #require(captured.emails.last?.passwordlessCode)
            #expect(firstCode != secondCode)

            // Old code should not work
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": firstCode
                ])
            }, afterResponse: { res in
                #expect(res.status == .unauthorized)
            })

            // New code should work
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": secondCode
                ])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    // MARK: - Email Magic Link Token Tests

    @Test("Passwordless login generates valid access token with correct claims")
    func passwordlessLoginGeneratesValidAccessToken() async throws {
        let captured = CapturedMessages()
        let email = "user@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request and verify code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.emails.first?.passwordlessCode)

            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                let authUser = try res.content.decode(AuthUser.self)

                // Verify access token by decoding it
                let req = Request(application: app, on: app.eventLoopGroup.any())
                let payload = try await req.jwt.verify(authUser.accessToken, as: AccessToken.self)

                #expect(payload.issuer?.value == "test-issuer")
                #expect(!payload.subject.value.isEmpty)
                #expect(payload.expiration.value > Date())
            })
        }
    }

    @Test("Passwordless login generates refresh token stored in database")
    func passwordlessLoginGeneratesRefreshToken() async throws {
        let captured = CapturedMessages()
        let email = "user@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request and verify code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.emails.first?.passwordlessCode)

            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                let authUser = try res.content.decode(AuthUser.self)

                // Verify refresh token is in store
                let store = app.passage.storage.services.store
                let random = app.passage.storage.services.random
                let hash = random.hashOpaqueToken(token: authUser.refreshToken)
                let refreshToken = try await store.tokens.find(refreshTokenHash: hash)

                #expect(refreshToken != nil)
                #expect(refreshToken?.isValid == true)
            })
        }
    }

    @Test("Passwordless login revokes previous refresh tokens")
    func passwordlessLoginRevokesOldTokens() async throws {
        let captured = CapturedMessages()
        let email = "user@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // First passwordless login
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()
            var code = try #require(captured.emails.first?.passwordlessCode)

            var firstRefreshToken = ""
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let authUser = try res.content.decode(AuthUser.self)
                firstRefreshToken = authUser.refreshToken
            })

            // Second passwordless login
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()
            code = try #require(captured.emails.last?.passwordlessCode)

            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let secondAuth = try res.content.decode(AuthUser.self)

                // First token should be revoked
                let store = app.passage.storage.services.store
                let random = app.passage.storage.services.random
                let firstHash = random.hashOpaqueToken(token: firstRefreshToken)
                let firstToken = try await store.tokens.find(refreshTokenHash: firstHash)

                #expect(firstToken?.revokedAt != nil)

                // Second token should be valid
                let secondHash = random.hashOpaqueToken(token: secondAuth.refreshToken)
                let secondToken = try await store.tokens.find(refreshTokenHash: secondHash)

                #expect(secondToken?.isValid == true)
            })
        }
    }

    @Test("Passwordless creates new user when email doesn't exist")
    func passwordlessCreatesNewUserForEmail() async throws {
        let captured = CapturedMessages()
        let email = "brand-new@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Verify user doesn't exist
            let store = app.passage.storage.services.store
            let userBefore = try await store.users.find(byIdentifier: Identifier(kind: .email, value: email))
            #expect(userBefore == nil)

            // Request and verify code
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.emails.first?.passwordlessCode)

            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": email,
                    "code": code
                ])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            // Verify user now exists
            let userAfter = try await store.users.find(byIdentifier: Identifier(kind: .email, value: email))
            #expect(userAfter != nil)
            #expect(userAfter?.email == email)
            #expect(userAfter?.isEmailVerified == true)
        }
    }

    // MARK: - Phone OTP Tests

    // MARK: Phone OTP Request Tests

    @Test("Request passwordless code via phone succeeds for new user", .disabled("OTP not yet implemented"))
    func requestPasswordlessPhoneNewUser() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            let phone = "+1234567890"

            try await app.testing().test(.POST, "/auth/otp/phone", beforeRequest: { req in
                try req.content.encode(["phone": phone])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            try await app.queues.queue.worker.run()

            #expect(captured.sms.count == 1)

            let sentSMS = try #require(captured.sms.first)
            #expect(sentSMS.to == phone)
            #expect(sentSMS.type == .passwordless)
            #expect(sentSMS.code != nil)
        }
    }

    @Test("Request passwordless code via phone succeeds for existing user", .disabled("OTP not yet implemented"))
    func requestPasswordlessPhoneExistingUser() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            let phone = "+1234567890"

            // Create existing user
            try await createTestUser(app: app, phone: phone, isPhoneVerified: true)

            try await app.testing().test(.POST, "/auth/otp/phone", beforeRequest: { req in
                try req.content.encode(["phone": phone])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            try await app.queues.queue.worker.run()

            #expect(captured.sms.count == 1)

            let sentSMS = try #require(captured.sms.first)
            #expect(sentSMS.to == phone)
            #expect(sentSMS.code != nil)
        }
    }

    @Test("Request passwordless code via phone fails when auto-create disabled and user doesn't exist", .disabled("OTP not yet implemented"))
    func requestPasswordlessPhoneFailsWhenAutoCreateDisabled() async throws {
        try await withApp(configure: { app in
            try await configureWithCapture(app, captured: nil, autoCreateUser: false)
        }) { app in
            try await app.testing().test(.POST, "/auth/otp/phone", beforeRequest: { req in
                try req.content.encode(["phone": "+9999999999"])
            }, afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }

    // MARK: Phone OTP Verify Tests

    @Test("Verify passwordless phone code succeeds and returns tokens for new user", .disabled("OTP not yet implemented"))
    func verifyPasswordlessPhoneNewUser() async throws {
        let captured = CapturedMessages()
        let phone = "+1234567890"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Step 1: Request passwordless code
            try await app.testing().test(.POST, "/auth/otp/phone", beforeRequest: { req in
                try req.content.encode(["phone": phone])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            try await app.queues.queue.worker.run()

            let code = try #require(captured.sms.first?.code)

            // Step 2: Verify code and get tokens
            try await app.testing().test(.POST, "/auth/otp/phone/verify", beforeRequest: { req in
                try req.content.encode([
                    "phone": phone,
                    "code": code
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                let authUser = try res.content.decode(AuthUser.self)
                #expect(authUser.user.phone == phone)
                #expect(!authUser.accessToken.isEmpty)
                #expect(!authUser.refreshToken.isEmpty)
                #expect(authUser.tokenType == "Bearer")
            })
        }
    }

    @Test("Verify passwordless phone code succeeds for existing user", .disabled("OTP not yet implemented"))
    func verifyPasswordlessPhoneExistingUser() async throws {
        let captured = CapturedMessages()
        let phone = "+1234567890"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Create existing user
            try await createTestUser(app: app, phone: phone, isPhoneVerified: true)

            // Get user ID before passwordless login
            let store = app.passage.storage.services.store
            let existingUser = try await store.users.find(byIdentifier: Identifier(kind: .phone, value: phone))
            let existingUserId = try #require(existingUser?.id?.description)

            // Request and verify code
            try await app.testing().test(.POST, "/auth/otp/phone", beforeRequest: { req in
                try req.content.encode(["phone": phone])
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.sms.first?.code)

            try await app.testing().test(.POST, "/auth/otp/phone/verify", beforeRequest: { req in
                try req.content.encode([
                    "phone": phone,
                    "code": code
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                let authUser = try res.content.decode(AuthUser.self)
                // Should be the same user
                #expect(authUser.user.id == existingUserId)
            })
        }
    }

    @Test("Verify passwordless phone code marks phone as verified", .disabled("OTP not yet implemented"))
    func verifyPasswordlessPhoneMarksVerified() async throws {
        let captured = CapturedMessages()
        let phone = "+1234567890"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request and verify code
            try await app.testing().test(.POST, "/auth/otp/phone", beforeRequest: { req in
                try req.content.encode(["phone": phone])
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.sms.first?.code)

            try await app.testing().test(.POST, "/auth/otp/phone/verify", beforeRequest: { req in
                try req.content.encode([
                    "phone": phone,
                    "code": code
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
            })

            // Check user in store is marked as verified
            let store = app.passage.storage.services.store
            let user = try await store.users.find(byIdentifier: Identifier(kind: .phone, value: phone))
            #expect(user?.isPhoneVerified == true)
        }
    }

    @Test("Verify passwordless phone code fails with invalid code", .disabled("OTP not yet implemented"))
    func verifyPasswordlessPhoneFailsWithInvalidCode() async throws {
        let captured = CapturedMessages()
        let phone = "+1234567890"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request code
            try await app.testing().test(.POST, "/auth/otp/phone", beforeRequest: { req in
                try req.content.encode(["phone": phone])
            })

            try await app.queues.queue.worker.run()

            // Try with wrong code
            try await app.testing().test(.POST, "/auth/otp/phone/verify", beforeRequest: { req in
                try req.content.encode([
                    "phone": phone,
                    "code": "wrongcode"
                ])
            }, afterResponse: { res in
                #expect(res.status == .unauthorized)
            })
        }
    }

    @Test("Resend passwordless phone code invalidates old code", .disabled("OTP not yet implemented"))
    func resendPasswordlessPhoneCodeInvalidatesOldCode() async throws {
        let captured = CapturedMessages()
        let phone = "+1234567890"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request initial code
            try await app.testing().test(.POST, "/auth/otp/phone", beforeRequest: { req in
                try req.content.encode(["phone": phone])
            })

            try await app.queues.queue.worker.run()
            let firstCode = try #require(captured.sms.first?.code)

            // Resend code
            try await app.testing().test(.POST, "/auth/otp/phone/resend", beforeRequest: { req in
                try req.content.encode(["phone": phone])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            try await app.queues.queue.worker.run()

            #expect(captured.sms.count == 2)
            let secondCode = try #require(captured.sms.last?.code)
            #expect(firstCode != secondCode)

            // Old code should not work
            try await app.testing().test(.POST, "/auth/otp/phone/verify", beforeRequest: { req in
                try req.content.encode([
                    "phone": phone,
                    "code": firstCode
                ])
            }, afterResponse: { res in
                #expect(res.status == .unauthorized)
            })

            // New code should work
            try await app.testing().test(.POST, "/auth/otp/phone/verify", beforeRequest: { req in
                try req.content.encode([
                    "phone": phone,
                    "code": secondCode
                ])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    // MARK: Phone OTP User Creation Tests

    @Test("Passwordless creates new user when phone doesn't exist", .disabled("OTP not yet implemented"))
    func passwordlessCreatesNewUserForPhone() async throws {
        let captured = CapturedMessages()
        let phone = "+1999888777"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Verify user doesn't exist
            let store = app.passage.storage.services.store
            let userBefore = try await store.users.find(byIdentifier: Identifier(kind: .phone, value: phone))
            #expect(userBefore == nil)

            // Request and verify code
            try await app.testing().test(.POST, "/auth/otp/phone", beforeRequest: { req in
                try req.content.encode(["phone": phone])
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.sms.first?.code)

            try await app.testing().test(.POST, "/auth/otp/phone/verify", beforeRequest: { req in
                try req.content.encode([
                    "phone": phone,
                    "code": code
                ])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            // Verify user now exists
            let userAfter = try await store.users.find(byIdentifier: Identifier(kind: .phone, value: phone))
            #expect(userAfter != nil)
            #expect(userAfter?.phone == phone)
            #expect(userAfter?.isPhoneVerified == true)
        }
    }

    // MARK: - Edge Cases

    @Test("Passwordless works correctly with different email casing")
    func passwordlessEmailCaseInsensitive() async throws {
        let captured = CapturedMessages()
        let email = "User@Example.COM"
        let normalizedEmail = "user@example.com"

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Request with uppercase email
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })

            try await app.queues.queue.worker.run()
            let code = try #require(captured.emails.first?.passwordlessCode)

            // Verify with lowercase email should work
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode([
                    "email": normalizedEmail,
                    "code": code
                ])
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("Multiple passwordless users can exist with different identifiers", .disabled("OTP not yet implemented"))
    func multiplePasswordlessUsers() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            let email1 = "user1@example.com"
            let email2 = "user2@example.com"
            let phone1 = "+1111111111"

            // Create first email user
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email1])
            })
            try await app.queues.queue.worker.run()
            var code = try #require(captured.emails.last?.passwordlessCode)

            var user1Id = ""
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode(["email": email1, "code": code])
            }, afterResponse: { res async throws in
                let authUser = try res.content.decode(AuthUser.self)
                user1Id = authUser.user.id
            })

            // Create second email user
            try await app.testing().test(.POST, "/auth/magic-link/email", beforeRequest: { req in
                try req.content.encode(["email": email2])
            })
            try await app.queues.queue.worker.run()
            code = try #require(captured.emails.last?.passwordlessCode)

            var user2Id = ""
            try await app.testing().test(.POST, "/auth/magic-link/email/verify", beforeRequest: { req in
                try req.content.encode(["email": email2, "code": code])
            }, afterResponse: { res async throws in
                let authUser = try res.content.decode(AuthUser.self)
                user2Id = authUser.user.id
            })

            // Create phone user
            try await app.testing().test(.POST, "/auth/otp/phone", beforeRequest: { req in
                try req.content.encode(["phone": phone1])
            })
            try await app.queues.queue.worker.run()
            code = try #require(captured.sms.last?.code)

            var user3Id = ""
            try await app.testing().test(.POST, "/auth/otp/phone/verify", beforeRequest: { req in
                try req.content.encode(["phone": phone1, "code": code])
            }, afterResponse: { res async throws in
                let authUser = try res.content.decode(AuthUser.self)
                user3Id = authUser.user.id
            })

            // All users should have different IDs
            #expect(user1Id != user2Id)
            #expect(user1Id != user3Id)
            #expect(user2Id != user3Id)
        }
    }
}
