import Vapor
import JWT

public struct Passage: Sendable {

    init(app: Application) {
        self.app = app
    }

    let app: Application

    // MARK: - Configuration

    public func configure(
        services: Services,
        configuration: Configuration,
    ) async throws {

        self.storage = Storage(services: services, configuration: configuration)

        try await app.jwt.keys.add(jwksJSON: configuration.jwt.jwks.json)

        try app.register(collection: PassageRouteCollection(routes: configuration.routes))

        if let _ = services.emailDelivery {
            // Register email verification routes if delivery is provided
            try app.register(collection: EmailVerificationRouteCollection(
                config: configuration.verification.email,
                groupPath: configuration.routes.group
            ))
            // Register email password reset routes if delivery is provided
            try app.register(collection: EmailRestorationRouteCollection(
                config: configuration.restoration.email,
                groupPath: configuration.routes.group
            ))
            // Register password reset web form if enabled
            if configuration.restoration.email.webForm.enabled {
                try app.register(collection: PasswordResetFormRouteCollection(
                    config: configuration,
                    groupPath: configuration.routes.group
                ))
            }
        }

        if let _ = services.phoneDelivery {
            // Register phone verification routes if delivery is provided
            try app.register(collection: PhoneVerificationRouteCollection(
                config: configuration.verification.phone,
                groupPath: configuration.routes.group
            ))
            // Register phone password reset routes if delivery is provided
            try app.register(collection: PhoneRestorationRouteCollection(
                config: configuration.restoration.phone,
                groupPath: configuration.routes.group
            ))
        }

        // Register verification jobs if queues are enabled
        if configuration.verification.useQueues {
            app.queues.add(Verification.SendEmailCodeJob())
            app.queues.add(Verification.SendPhoneCodeJob())
        }

        // Register restoration jobs if queues are enabled
        if configuration.restoration.useQueues {
            app.queues.add(Restoration.SendEmailResetCodeJob())
            app.queues.add(Restoration.SendPhoneResetCodeJob())
        }

        try oauth.register(config: configuration)
    }

}

// MARK: - Storage Accessors

extension Passage {

    var services: Services {
        storage.services
    }

    var configuration: Configuration {
        storage.configuration
    }

}
