import Testing
import Vapor
import Queues
@testable import Passage
@testable import PassageOnlyForTest

@Suite("Restoration Jobs Tests", .tags(.unit))
struct RestorationJobsTests {

    // MARK: - Helper Types

    /// Mock logger that captures logged messages for testing
    final class CapturingLogger: LogHandler, @unchecked Sendable {
        var metadata: Logger.Metadata = [:]
        var logLevel: Logger.Level = .trace

        private(set) var warnings: [String] = []
        private(set) var errors: [String] = []

        subscript(metadataKey key: String) -> Logger.Metadata.Value? {
            get { metadata[key] }
            set { metadata[key] = newValue }
        }

        func log(
            level: Logger.Level,
            message: Logger.Message,
            metadata: Logger.Metadata?,
            source: String,
            file: String,
            function: String,
            line: UInt
        ) {
            let messageString = message.description
            switch level {
            case .warning:
                warnings.append(messageString)
            case .error, .critical:
                errors.append(messageString)
            default:
                break
            }
        }
    }

    /// Mock error for testing error handling
    struct MockDeliveryError: Error, Equatable {
        let message: String
    }

    /// Email delivery that always throws an error
    struct FailingEmailDelivery: Passage.EmailDelivery, Sendable {
        let error: Error

        init(error: Error = MockDeliveryError(message: "Email delivery failed")) {
            self.error = error
        }

        func sendEmailVerification(
            to email: String,
            user: any User,
            verificationURL: URL,
            verificationCode: String
        ) async throws {
            throw error
        }

        func sendEmailVerificationConfirmation(to email: String, user: any User) async throws {
            throw error
        }

        func sendPasswordResetEmail(
            to email: String,
            user: any User,
            passwordResetURL: URL,
            passwordResetCode: String
        ) async throws {
            throw error
        }

        func sendWelcomeEmail(to email: String, user: any User) async throws {
            throw error
        }
    }

    /// Phone delivery that always throws an error
    struct FailingPhoneDelivery: Passage.PhoneDelivery, Sendable {
        let error: Error

        init(error: Error = MockDeliveryError(message: "Phone delivery failed")) {
            self.error = error
        }

        func sendPhoneVerification(to phone: String, code: String, user: any User) async throws {
            throw error
        }

        func sendVerificationConfirmation(to phone: String, user: any User) async throws {
            throw error
        }

        func sendPasswordResetSMS(to phone: String, code: String, user: any User) async throws {
            throw error
        }
    }

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

    // MARK: - SendEmailPasswordResetCodeJob Tests

    @Test("SendEmailPasswordResetCodeJob skips when email delivery is not configured")
    func sendEmailResetJobSkipsWhenNoEmailDelivery() async throws {
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
        let payload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: user!.id!.description,
            resetURL: URL(string: "http://localhost:8080/reset")!,
            resetCode: "123456"
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job
        let job = Passage.Restoration.SendEmailPasswordResetCodeJob()
        try await job.dequeue(context, payload)

        // Verify warning was logged
        #expect(capturingLogger.warnings.count == 1)
        #expect(capturingLogger.warnings.first?.contains("Email delivery not configured") == true)
        #expect(capturingLogger.warnings.first?.contains("password reset job") == true)
    }

    @Test("SendEmailPasswordResetCodeJob skips when user is not found")
    func sendEmailResetJobSkipsWhenUserNotFound() async throws {
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
        let payload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: "non-existent-user-id",
            resetURL: URL(string: "http://localhost:8080/reset")!,
            resetCode: "123456"
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job
        let job = Passage.Restoration.SendEmailPasswordResetCodeJob()
        try await job.dequeue(context, payload)

        // Verify warning was logged
        #expect(capturingLogger.warnings.count == 1)
        #expect(capturingLogger.warnings.first?.contains("User not found") == true)
        #expect(capturingLogger.warnings.first?.contains("password reset job") == true)
        #expect(capturingLogger.warnings.first?.contains("non-existent-user-id") == true)
    }

    @Test("SendEmailPasswordResetCodeJob error handler logs delivery errors")
    func sendEmailResetJobErrorHandlerLogsErrors() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }

        // Create job payload
        let payload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: "user123",
            resetURL: URL(string: "http://localhost:8080/reset")!,
            resetCode: "123456"
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Create the job and trigger error handler
        let job = Passage.Restoration.SendEmailPasswordResetCodeJob()
        let testError = MockDeliveryError(message: "SMTP connection failed")
        try await job.error(context, testError, payload)

        // Verify error was logged
        #expect(capturingLogger.errors.count == 1)
        #expect(capturingLogger.errors.first?.contains("Failed to send password reset email") == true)
        #expect(capturingLogger.errors.first?.contains("test@example.com") == true)
    }

    @Test("SendEmailPasswordResetCodeJob throws error from email delivery")
    func sendEmailResetJobThrowsDeliveryError() async throws {
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
        let payload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: user!.id!.description,
            resetURL: URL(string: "http://localhost:8080/reset")!,
            resetCode: "123456"
        )

        // Create queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job and expect it to throw
        let job = Passage.Restoration.SendEmailPasswordResetCodeJob()
        await #expect(throws: MockDeliveryError.self) {
            try await job.dequeue(context, payload)
        }
    }

    // MARK: - SendPhonePasswordResetCodeJob Tests

    @Test("SendPhonePasswordResetCodeJob skips when phone delivery is not configured")
    func sendPhoneResetJobSkipsWhenNoPhoneDelivery() async throws {
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
        let payload = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+1234567890",
            code: "123456",
            userId: user!.id!.description
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job
        let job = Passage.Restoration.SendPhonePasswordResetCodeJob()
        try await job.dequeue(context, payload)

        // Verify warning was logged
        #expect(capturingLogger.warnings.count == 1)
        #expect(capturingLogger.warnings.first?.contains("Phone delivery not configured") == true)
        #expect(capturingLogger.warnings.first?.contains("password reset job") == true)
    }

    @Test("SendPhonePasswordResetCodeJob skips when user is not found")
    func sendPhoneResetJobSkipsWhenUserNotFound() async throws {
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
        let payload = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+1234567890",
            code: "123456",
            userId: "non-existent-user-id"
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job
        let job = Passage.Restoration.SendPhonePasswordResetCodeJob()
        try await job.dequeue(context, payload)

        // Verify warning was logged
        #expect(capturingLogger.warnings.count == 1)
        #expect(capturingLogger.warnings.first?.contains("User not found") == true)
        #expect(capturingLogger.warnings.first?.contains("phone password reset job") == true)
        #expect(capturingLogger.warnings.first?.contains("non-existent-user-id") == true)
    }

    @Test("SendPhonePasswordResetCodeJob error handler logs delivery errors")
    func sendPhoneResetJobErrorHandlerLogsErrors() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }

        // Create job payload
        let payload = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+1234567890",
            code: "123456",
            userId: "user123"
        )

        // Create capturing logger and queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Create the job and trigger error handler
        let job = Passage.Restoration.SendPhonePasswordResetCodeJob()
        let testError = MockDeliveryError(message: "SMS service unavailable")
        try await job.error(context, testError, payload)

        // Verify error was logged
        #expect(capturingLogger.errors.count == 1)
        #expect(capturingLogger.errors.first?.contains("Failed to send password reset SMS") == true)
        #expect(capturingLogger.errors.first?.contains("+1234567890") == true)
    }

    @Test("SendPhonePasswordResetCodeJob throws error from phone delivery")
    func sendPhoneResetJobThrowsDeliveryError() async throws {
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
        let payload = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+1234567890",
            code: "123456",
            userId: user!.id!.description
        )

        // Create queue context
        let capturingLogger = CapturingLogger()
        let context = createMockQueueContext(app: app, logger: capturingLogger)

        // Execute the job and expect it to throw
        let job = Passage.Restoration.SendPhonePasswordResetCodeJob()
        await #expect(throws: MockDeliveryError.self) {
            try await job.dequeue(context, payload)
        }
    }

    // MARK: - Job Conformance Tests

    @Test("SendEmailPasswordResetCodeJob conforms to AsyncJob")
    func sendEmailResetJobConformsToAsyncJob() {
        let job = Passage.Restoration.SendEmailPasswordResetCodeJob()
        let _: any AsyncJob = job
        #expect(Passage.Restoration.SendEmailPasswordResetCodeJob.self is AsyncJob.Type)
    }

    @Test("SendPhonePasswordResetCodeJob conforms to AsyncJob")
    func sendPhoneResetJobConformsToAsyncJob() {
        let job = Passage.Restoration.SendPhonePasswordResetCodeJob()
        let _: any AsyncJob = job
        #expect(Passage.Restoration.SendPhonePasswordResetCodeJob.self is AsyncJob.Type)
    }

    @Test("SendEmailPasswordResetCodeJob has correct payload type")
    func sendEmailResetJobPayloadType() {
        #expect(
            Passage.Restoration.SendEmailPasswordResetCodeJob.Payload.self
                == Passage.Restoration.EmailPasswordResetCodePayload.self
        )
    }

    @Test("SendPhonePasswordResetCodeJob has correct payload type")
    func sendPhoneResetJobPayloadType() {
        #expect(
            Passage.Restoration.SendPhonePasswordResetCodeJob.Payload.self
                == Passage.Restoration.PhonePasswordResetCodePayload.self
        )
    }
}
