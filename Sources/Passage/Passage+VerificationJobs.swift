import Vapor
import Queues

// MARK: - Email Verification Job

extension Passage.Verification {

    /// Job payload for sending email verification
    struct SendEmailCodePayload: Codable {
        let email: String
        let userId: String
        let verificationURL: URL
        let verificationCode: String
    }

    /// Async job for sending email verification codes
    struct SendEmailCodeJob: AsyncJob {
        typealias Payload = SendEmailCodePayload

        func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
            let identity = context.application.passage

            guard let delivery = identity.emailDelivery else {
                context.logger.warning("Email delivery not configured, skipping job")
                return
            }

            guard let user = try await identity.store.users.find(byId: payload.userId) else {
                context.logger.warning("User not found for email verification job: \(payload.userId)")
                return
            }

            try await delivery.sendEmailVerification(
                to: payload.email,
                user: user,
                verificationURL: payload.verificationURL,
                verificationCode: payload.verificationCode
            )
        }

        func error(_ context: QueueContext, _ error: any Error, _ payload: Payload) async throws {
            context.logger.error("Failed to send email verification to \(payload.email): \(error)")
        }
    }
}

// MARK: - Phone Verification Job

extension Passage.Verification {

    /// Job payload for sending phone verification
    struct SendPhoneCodePayload: Codable {
        let phone: String
        let code: String
        let userId: String
    }

    /// Async job for sending phone verification codes
    struct SendPhoneCodeJob: AsyncJob {
        typealias Payload = SendPhoneCodePayload

        func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
            guard let delivery = context.application.passage.phoneDelivery else {
                context.logger.warning("Phone delivery not configured, skipping job")
                return
            }

            guard let user = try await context.application.passage.store.users.find(byId: payload.userId) else {
                context.logger.warning("User not found for phone verification job: \(payload.userId)")
                return
            }

            try await delivery.sendPhoneVerification(
                to: payload.phone,
                code: payload.code,
                user: user
            )
        }

        func error(_ context: QueueContext, _ error: any Error, _ payload: Payload) async throws {
            context.logger.error("Failed to send phone verification to \(payload.phone): \(error)")
        }
    }
}
