//
//  Identity.swift
//  passten
//
//  Created by Max Rozdobudko on 11/6/25.
//

import Vapor

struct Identity: Sendable {

    init(app: Application) {
        self.app = app
    }

    private let app: Application

    // MARK: - Configuration

    func configure(
        services: Services,
        configuration: Configuration,
    ) async throws {

        app.identityStorage = Storage(services: services, configuration: configuration)

        try await app.jwt.keys.add(jwksJSON: configuration.jwt.jwks.json)

        try app.register(collection: IdentityRouteCollection(routes: configuration.routes))

        // Register email verification routes if delivery is provided
        if let _ = services.emailDelivery {
            try app.register(collection: EmailVerificationRouteCollection(
                config: configuration.verification.email,
                groupPath: configuration.routes.group
            ))
        }

        // Register phone verification routes if delivery is provided
        if let _ = services.phoneDelivery {
            try app.register(collection: PhoneVerificationRouteCollection(
                config: configuration.verification.phone,
                groupPath: configuration.routes.group
            ))
        }

        // Register verification jobs if queues are enabled
        if configuration.verification.useQueues {
            app.queues.add(Verification.SendEmailCodeJob())
            app.queues.add(Verification.SendPhoneCodeJob())
        }
    }

}

// MARK: - Storage Accessors

extension Identity {

    var storage: Storage {
        app.identityStorage
    }

    var services: Services {
        storage.services
    }

    var configuration: Configuration {
        storage.configuration
    }

}
