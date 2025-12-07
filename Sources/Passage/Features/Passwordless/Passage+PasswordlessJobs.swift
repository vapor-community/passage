import Vapor
import Queues

// MARK: - Email Magic Link Job

extension Passage.Passwordless {

    /// Job payload for sending email magic link
    struct EmailMagicLinkPayload: Codable {
        let email: String
        let userId: String?
        let magicLinkURL: URL
    }

    /// Async job for sending email magic links
    struct SendEmailMagicLinkJob: AsyncJob {
        typealias Payload = EmailMagicLinkPayload

        func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
            let identity = context.application.passage

            guard let delivery = identity.emailDelivery else {
                context.logger.warning("Email delivery not configured, skipping magic link job")
                return
            }

            // User may be nil for new users (when auto-create is enabled)
            let user: (any User)? = if let userId = payload.userId {
                try await identity.store.users.find(byId: userId)
            } else {
                nil
            }

            try await delivery.sendMagicLinkEmail(
                to: payload.email,
                user: user,
                magicLinkURL: payload.magicLinkURL
            )
        }

        func error(_ context: QueueContext, _ error: any Error, _ payload: Payload) async throws {
            context.logger.error("Failed to send magic link email to \(payload.email): \(error)")
        }
    }

}
