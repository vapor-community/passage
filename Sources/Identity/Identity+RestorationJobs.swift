import Vapor
import Queues

// MARK: - Email Reset Job

extension Identity.Restoration {

    /// Job payload for sending email password reset
    struct SendEmailResetCodePayload: Codable {
        let email: String
        let userId: String
        let resetURL: URL
        let resetCode: String
    }

    /// Async job for sending email password reset codes
    struct SendEmailResetCodeJob: AsyncJob {
        typealias Payload = SendEmailResetCodePayload

        func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
            let identity = context.application.identity

            guard let delivery = identity.emailDelivery else {
                context.logger.warning("Email delivery not configured, skipping password reset job")
                return
            }

            guard let user = try await identity.store.users.find(byId: payload.userId) else {
                context.logger.warning("User not found for password reset job: \(payload.userId)")
                return
            }

            try await delivery.sendPasswordResetEmail(
                to: payload.email,
                user: user,
                passwordResetURL: payload.resetURL,
                passwordResetCode: payload.resetCode
            )
        }

        func error(_ context: QueueContext, _ error: any Error, _ payload: Payload) async throws {
            context.logger.error("Failed to send password reset email to \(payload.email): \(error)")
        }
    }
}

// MARK: - Phone Reset Job

extension Identity.Restoration {

    /// Job payload for sending phone password reset
    struct SendPhoneResetCodePayload: Codable {
        let phone: String
        let code: String
        let userId: String
    }

    /// Async job for sending phone password reset codes
    struct SendPhoneResetCodeJob: AsyncJob {
        typealias Payload = SendPhoneResetCodePayload

        func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
            guard let delivery = context.application.identity.phoneDelivery else {
                context.logger.warning("Phone delivery not configured, skipping password reset job")
                return
            }

            guard let user = try await context.application.identity.store.users.find(byId: payload.userId) else {
                context.logger.warning("User not found for phone password reset job: \(payload.userId)")
                return
            }

            try await delivery.sendPasswordResetSMS(
                to: payload.phone,
                code: payload.code,
                user: user
            )
        }

        func error(_ context: QueueContext, _ error: any Error, _ payload: Payload) async throws {
            context.logger.error("Failed to send password reset SMS to \(payload.phone): \(error)")
        }
    }
}
