//
//  IdentityProvider.swift
//  passten
//
//  Created by Max Rozdobudko on 11/28/25.
//

import Vapor

// MARK: - Storage

extension Identity {

    final class Storage: @unchecked Sendable {
        struct Key: StorageKey {
            typealias Value = Storage
        }

        let services: Services
        let configuration: Configuration

        init(
            services: Services,
            configuration: Configuration
        ) {
            self.services = services
            self.configuration = configuration
        }
    }
}

extension Identity {

    var storage: Identity.Storage {
        get {
            guard let storage = app.storage[Identity.Storage.Key.self] else {
                fatalError("""
                    Identity not configured. Call app.identity.configure() during application setup.
                    Example:
                        try await app.identity.configure(
                            services: .init(store: ..., emailDelivery: ...),
                            configuration: .init(routes: .init(group: "api", "auth"), ...)
                        )
                    """)
            }
            return storage
        }
        nonmutating set {
            guard app.storage[Identity.Storage.Key.self] == nil else {
                fatalError("""
                    Identity storage has already been set.
                    Make sure to call app.identity.configure() only once during application setup.
                    """)
            }
            app.storage[Identity.Storage.Key.self] = newValue
        }
    }
}

// MARK: - Application Support

extension Application {

    var identity: Identity {
        Identity(app: self)
    }

}

// MARK: - Request Support

extension Request {

    var store: any Identity.Store {
        application.identity.store
    }

    var emailDelivery: (any Identity.EmailDelivery)? {
        application.identity.emailDelivery
    }

    var phoneDelivery: (any Identity.PhoneDelivery)? {
        application.identity.phoneDelivery
    }

    var configuration: Identity.Configuration {
        application.identity.configuration
    }

    var tokens: Identity.Configuration.Tokens {
        configuration.tokens
    }

    var random: any Identity.RandomGenerator {
        application.identity.random
    }

}
