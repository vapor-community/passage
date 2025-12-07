import Vapor
@testable import Passage

// MARK: - Capturing Logger for Testing

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


// MARK: - Failing Delivery Implementations for Testing

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

    func sendMagicLinkEmail(to email: String, user: (any User)?, magicLinkURL: URL) async throws {
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
