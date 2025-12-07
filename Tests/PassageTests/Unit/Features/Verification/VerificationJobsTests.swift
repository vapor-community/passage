import Testing
import Vapor
import Queues
@testable import Passage
@testable import PassageOnlyForTest

@Suite("Verification Jobs Tests", .tags(.unit))
struct VerificationJobsTests {
    /// Creates a mock QueueContext for testing
    @Sendable private func createMockQueueContext(
        app: Application,
        logger: CapturingLogger
    ) -> QueueContext {
        return QueueContext(
            queueName: .init(string: "test"),
            configuration: .init(),
            application: app,
            logger: Logger(label: "test", factory: { _ in logger }),
            on: app.eventLoopGroup.next()
        )
    }

    // MARK: - SendEmailCodeJob Tests

    @Test("SendEmailCodeJob skips when email delivery is not configured")
    func sendEmailJobSkipsWhenNoEmailDelivery() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }

        // Configure Passage without email delivery
        let store = Passage.OnlyForTest.InMemoryStore()
        let services = Passage.Services(
            store: store,
            random: DefaultRandomGenerator(),
            emailDelivery: nil, // No email delivery configured
            phoneDelivery: nil,
            federatedLogin: nil
        )

        let emptyJwks = """
        {"keys":[]}
        """

        let configuration = try Passage.Configuration(
            origin: URL(string: "http://localhost:8080")!,
            routes: .init(),
            tokens: .init(
                issuer: "test-issuer",
                accessToken: .init(timeToLive: 3600),
                refreshToken: .init(timeToLive: 86400)
            ),
            jwt: .init(jwks: .init(json: emptyJwks))
        )

        try await app.passage.configure(services: services, configuration: configuration)

        // Create a test user
        let passwordHash = try await app.password.async.hash("password123")
        let credential = Credential.email(email: "test@example.com", passwordHash: passwordHash)
        try await store.users.create(with: credential)

        let user = try await store.users.find(byCredential: credential)
        #expect(user != nil)

        // Create job payload
        let payload = Passage.Verification.SendEmailCodePayload(
            email: "test@example.com",
            userId: user!.id!.description,
            verificationURL: URL(string: "http://localhost:8080/verify")!,
            verificationCode: "123456"
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job
        let job = Passage.Verification.SendEmailCodeJob()
        try await job.dequeue(context, payload)

        // Verify warning was logged
        #expect(capturingLogger.warnings.count == 1)
        #expect(capturingLogger.warnings.first?.contains("Email delivery not configured") == true)
    }

    @Test("SendEmailCodeJob skips when user is not found")
    func sendEmailJobSkipsWhenUserNotFound() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }

        // Configure Passage with email delivery
        let store = Passage.OnlyForTest.InMemoryStore()
        let emailDelivery = Passage.OnlyForTest.MockEmailDelivery()
        let services = Passage.Services(
            store: store,
            random: DefaultRandomGenerator(),
            emailDelivery: emailDelivery,
            phoneDelivery: nil,
            federatedLogin: nil
        )

        let emptyJwks = """
        {"keys":[]}
        """

        let configuration = try Passage.Configuration(
            origin: URL(string: "http://localhost:8080")!,
            routes: .init(),
            tokens: .init(
                issuer: "test-issuer",
                accessToken: .init(timeToLive: 3600),
                refreshToken: .init(timeToLive: 86400)
            ),
            jwt: .init(jwks: .init(json: emptyJwks))
        )

        try await app.passage.configure(services: services, configuration: configuration)

        // Create job payload with non-existent user ID
        let payload = Passage.Verification.SendEmailCodePayload(
            email: "test@example.com",
            userId: "non-existent-user-id",
            verificationURL: URL(string: "http://localhost:8080/verify")!,
            verificationCode: "123456"
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job
        let job = Passage.Verification.SendEmailCodeJob()
        try await job.dequeue(context, payload)

        // Verify warning was logged
        #expect(capturingLogger.warnings.count == 1)
        #expect(capturingLogger.warnings.first?.contains("User not found") == true)
        #expect(capturingLogger.warnings.first?.contains("non-existent-user-id") == true)
    }

    @Test("SendEmailCodeJob error handler logs delivery errors")
    func sendEmailJobErrorHandlerLogsErrors() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }

        // Create job payload
        let payload = Passage.Verification.SendEmailCodePayload(
            email: "test@example.com",
            userId: "user123",
            verificationURL: URL(string: "http://localhost:8080/verify")!,
            verificationCode: "123456"
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Create the job and trigger error handler
        let job = Passage.Verification.SendEmailCodeJob()
        let testError = MockDeliveryError(message: "SMTP connection failed")
        try await job.error(context, testError, payload)

        // Verify error was logged
        #expect(capturingLogger.errors.count == 1)
        #expect(capturingLogger.errors.first?.contains("Failed to send email verification") == true)
        #expect(capturingLogger.errors.first?.contains("test@example.com") == true)
    }

    @Test("SendEmailCodeJob throws error from email delivery")
    func sendEmailJobThrowsDeliveryError() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }

        // Configure Passage with failing email delivery
        let store = Passage.OnlyForTest.InMemoryStore()
        let testError = MockDeliveryError(message: "Network timeout")
        let emailDelivery = FailingEmailDelivery(error: testError)
        let services = Passage.Services(
            store: store,
            random: DefaultRandomGenerator(),
            emailDelivery: emailDelivery,
            phoneDelivery: nil,
            federatedLogin: nil
        )

        let emptyJwks = """
        {"keys":[]}
        """

        let configuration = try Passage.Configuration(
            origin: URL(string: "http://localhost:8080")!,
            routes: .init(),
            tokens: .init(
                issuer: "test-issuer",
                accessToken: .init(timeToLive: 3600),
                refreshToken: .init(timeToLive: 86400)
            ),
            jwt: .init(jwks: .init(json: emptyJwks))
        )

        try await app.passage.configure(services: services, configuration: configuration)

        // Create a test user
        let passwordHash = try await app.password.async.hash("password123")
        let credential = Credential.email(email: "test@example.com", passwordHash: passwordHash)
        try await store.users.create(with: credential)

        let user = try await store.users.find(byCredential: credential)
        #expect(user != nil)

        // Create job payload
        let payload = Passage.Verification.SendEmailCodePayload(
            email: "test@example.com",
            userId: user!.id!.description,
            verificationURL: URL(string: "http://localhost:8080/verify")!,
            verificationCode: "123456"
        )

        // Create queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job and expect it to throw
        let job = Passage.Verification.SendEmailCodeJob()
        await #expect(throws: MockDeliveryError.self) {
            try await job.dequeue(context, payload)
        }
    }

    // MARK: - SendPhoneCodeJob Tests

    @Test("SendPhoneCodeJob skips when phone delivery is not configured")
    func sendPhoneJobSkipsWhenNoPhoneDelivery() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }

        // Configure Passage without phone delivery
        let store = Passage.OnlyForTest.InMemoryStore()
        let services = Passage.Services(
            store: store,
            random: DefaultRandomGenerator(),
            emailDelivery: nil,
            phoneDelivery: nil, // No phone delivery configured
            federatedLogin: nil
        )

        let emptyJwks = """
        {"keys":[]}
        """

        let configuration = try Passage.Configuration(
            origin: URL(string: "http://localhost:8080")!,
            routes: .init(),
            tokens: .init(
                issuer: "test-issuer",
                accessToken: .init(timeToLive: 3600),
                refreshToken: .init(timeToLive: 86400)
            ),
            jwt: .init(jwks: .init(json: emptyJwks))
        )

        try await app.passage.configure(services: services, configuration: configuration)

        // Create a test user
        let passwordHash = try await app.password.async.hash("password123")
        let credential = Credential.phone(phone: "+1234567890", passwordHash: passwordHash)
        try await store.users.create(with: credential)

        let user = try await store.users.find(byCredential: credential)
        #expect(user != nil)

        // Create job payload
        let payload = Passage.Verification.SendPhoneCodePayload(
            phone: "+1234567890",
            code: "123456",
            userId: user!.id!.description
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job
        let job = Passage.Verification.SendPhoneCodeJob()
        try await job.dequeue(context, payload)

        // Verify warning was logged
        #expect(capturingLogger.warnings.count == 1)
        #expect(capturingLogger.warnings.first?.contains("Phone delivery not configured") == true)
    }

    @Test("SendPhoneCodeJob skips when user is not found")
    func sendPhoneJobSkipsWhenUserNotFound() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }

        // Configure Passage with phone delivery
        let store = Passage.OnlyForTest.InMemoryStore()
        let phoneDelivery = Passage.OnlyForTest.MockPhoneDelivery()
        let services = Passage.Services(
            store: store,
            random: DefaultRandomGenerator(),
            emailDelivery: nil,
            phoneDelivery: phoneDelivery,
            federatedLogin: nil
        )

        let emptyJwks = """
        {"keys":[]}
        """

        let configuration = try Passage.Configuration(
            origin: URL(string: "http://localhost:8080")!,
            routes: .init(),
            tokens: .init(
                issuer: "test-issuer",
                accessToken: .init(timeToLive: 3600),
                refreshToken: .init(timeToLive: 86400)
            ),
            jwt: .init(jwks: .init(json: emptyJwks))
        )

        try await app.passage.configure(services: services, configuration: configuration)

        // Create job payload with non-existent user ID
        let payload = Passage.Verification.SendPhoneCodePayload(
            phone: "+1234567890",
            code: "123456",
            userId: "non-existent-user-id"
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job
        let job = Passage.Verification.SendPhoneCodeJob()
        try await job.dequeue(context, payload)

        // Verify warning was logged
        #expect(capturingLogger.warnings.count == 1)
        #expect(capturingLogger.warnings.first?.contains("User not found") == true)
        #expect(capturingLogger.warnings.first?.contains("non-existent-user-id") == true)
    }

    @Test("SendPhoneCodeJob error handler logs delivery errors")
    func sendPhoneJobErrorHandlerLogsErrors() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }

        // Create job payload
        let payload = Passage.Verification.SendPhoneCodePayload(
            phone: "+1234567890",
            code: "123456",
            userId: "user123"
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Create the job and trigger error handler
        let job = Passage.Verification.SendPhoneCodeJob()
        let testError = MockDeliveryError(message: "SMS service unavailable")
        try await job.error(context, testError, payload)

        // Verify error was logged
        #expect(capturingLogger.errors.count == 1)
        #expect(capturingLogger.errors.first?.contains("Failed to send phone verification") == true)
        #expect(capturingLogger.errors.first?.contains("+1234567890") == true)
    }

    @Test("SendPhoneCodeJob throws error from phone delivery")
    func sendPhoneJobThrowsDeliveryError() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }

        // Configure Passage with failing phone delivery
        let store = Passage.OnlyForTest.InMemoryStore()
        let testError = MockDeliveryError(message: "SMS gateway error")
        let phoneDelivery = FailingPhoneDelivery(error: testError)
        let services = Passage.Services(
            store: store,
            random: DefaultRandomGenerator(),
            emailDelivery: nil,
            phoneDelivery: phoneDelivery,
            federatedLogin: nil
        )

        let emptyJwks = """
        {"keys":[]}
        """

        let configuration = try Passage.Configuration(
            origin: URL(string: "http://localhost:8080")!,
            routes: .init(),
            tokens: .init(
                issuer: "test-issuer",
                accessToken: .init(timeToLive: 3600),
                refreshToken: .init(timeToLive: 86400)
            ),
            jwt: .init(jwks: .init(json: emptyJwks))
        )

        try await app.passage.configure(services: services, configuration: configuration)

        // Create a test user
        let passwordHash = try await app.password.async.hash("password123")
        let credential = Credential.phone(phone: "+1234567890", passwordHash: passwordHash)
        try await store.users.create(with: credential)

        let user = try await store.users.find(byCredential: credential)
        #expect(user != nil)

        // Create job payload
        let payload = Passage.Verification.SendPhoneCodePayload(
            phone: "+1234567890",
            code: "123456",
            userId: user!.id!.description
        )

        // Create queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job and expect it to throw
        let job = Passage.Verification.SendPhoneCodeJob()
        await #expect(throws: MockDeliveryError.self) {
            try await job.dequeue(context, payload)
        }
    }

    // MARK: - Job Conformance Tests

    @Test("SendEmailCodeJob conforms to AsyncJob")
    func sendEmailJobConformsToAsyncJob() {
        let job = Passage.Verification.SendEmailCodeJob()
        let _: any AsyncJob = job
        #expect(Passage.Verification.SendEmailCodeJob.self is AsyncJob.Type)
    }

    @Test("SendPhoneCodeJob conforms to AsyncJob")
    func sendPhoneJobConformsToAsyncJob() {
        let job = Passage.Verification.SendPhoneCodeJob()
        let _: any AsyncJob = job
        #expect(Passage.Verification.SendPhoneCodeJob.self is AsyncJob.Type)
    }

    @Test("SendEmailCodeJob has correct payload type")
    func sendEmailJobPayloadType() {
        #expect(
            Passage.Verification.SendEmailCodeJob.Payload.self
                == Passage.Verification.SendEmailCodePayload.self
        )
    }

    @Test("SendPhoneCodeJob has correct payload type")
    func sendPhoneJobPayloadType() {
        #expect(
            Passage.Verification.SendPhoneCodeJob.Payload.self
                == Passage.Verification.SendPhoneCodePayload.self
        )
    }
}
