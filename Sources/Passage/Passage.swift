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
        contracts: Contracts = .init(),
        configuration: Configuration,
    ) async throws {

        self.storage = Storage(
            services: services,
            contracts: contracts,
            configuration: configuration
        )

        try await app.jwt.keys.add(jwksJSON: configuration.jwt.jwks.json)

        try app.register(collection: Identity.RouteCollection(routes: configuration.routes))

        if let _ = services.emailDelivery {
            // Register email verification routes if delivery is provided
            try app.register(collection: Verification.EmailRouteCollection(
                config: configuration.verification.email,
                group: configuration.routes.group
            ))
            // Register email password reset routes if delivery is provided
            try app.register(collection: Restoration.EmailRouteCollection(
                routes: configuration.restoration.email.routes,
                group: configuration.routes.group
            ))
            // Register password reset web form if enabled
//            if configuration.restoration.email.webForm.enabled {
//                try app.register(collection: PasswordResetFormRouteCollection(
//                    config: configuration,
//                    groupPath: configuration.routes.group
//                ))
//            }
        }

        if let _ = services.phoneDelivery {
            // Register phone verification routes if delivery is provided
            try app.register(collection: Verification.PhoneRouteCollection(
                config: configuration.verification.phone,
                groupPath: configuration.routes.group
            ))
            // Register phone password reset routes if delivery is provided
            try app.register(collection: Restoration.PhoneRouteCollection(
                routes: configuration.restoration.phone.routes,
                groupPath: configuration.routes.group
            ))
        }

        //
        if configuration.views.enabled {
            try Views.registerLeafTempleates(on: app)
            try app.register(collection: Views.RouteCollection(
                config: configuration.views,
                routes: configuration.routes,
                restoration: configuration.restoration,
                group: configuration.routes.group
            ))
        }

        // Register verification jobs if queues are enabled
        if configuration.verification.useQueues {
            app.queues.add(Verification.SendEmailCodeJob())
            app.queues.add(Verification.SendPhoneCodeJob())
        }

        // Register restoration jobs if queues are enabled
        if configuration.restoration.useQueues {
            app.queues.add(Restoration.SendEmailPasswordResetCodeJob())
            app.queues.add(Restoration.SendPhonePasswordResetCodeJob())
        }

        try oauth.register(config: configuration)
    }

}

// MARK: - Storage Accessors

extension Passage {

    var services: Services {
        storage.services
    }

    var contracts: Contracts {
        storage.contracts
    }

    var configuration: Configuration {
        storage.configuration
    }

}
