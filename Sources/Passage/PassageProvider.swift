import Vapor

// MARK: - Storage

extension Passage {

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

extension Passage {

    var storage: Passage.Storage {
        get {
            guard let storage = app.storage[Passage.Storage.Key.self] else {
                fatalError("""
                    Passage not configured. Call app.passage.configure() during application setup.
                    Example:
                        try await app.passage.configure(
                            services: .init(store: ..., emailDelivery: ...),
                            configuration: .init(routes: .init(group: "api", "auth"), ...)
                        )
                    """)
            }
            return storage
        }
        nonmutating set {
            guard app.storage[Passage.Storage.Key.self] == nil else {
                fatalError("""
                    Passage storage has already been set.
                    Make sure to call app.passage.configure() only once during application setup.
                    """)
            }
            app.storage[Passage.Storage.Key.self] = newValue
        }
    }
}

// MARK: - Application Support

public extension Application {

    var passage: Passage {
        Passage(app: self)
    }

}

// MARK: - Request Support

extension Request {

    var store: any Passage.Store {
        application.passage.store
    }

    var emailDelivery: (any Passage.EmailDelivery)? {
        application.passage.emailDelivery
    }

    var phoneDelivery: (any Passage.PhoneDelivery)? {
        application.passage.phoneDelivery
    }

    var configuration: Passage.Configuration {
        application.passage.configuration
    }

    var tokens: Passage.Configuration.Tokens {
        configuration.tokens
    }

    var random: any Passage.RandomGenerator {
        application.passage.random
    }

}
