import Vapor

// MARK: - Federated Login Configuration

public extension Passage.Configuration {

    struct FederatedLogin: Sendable {
        public struct Routes: Sendable {
            let group: [PathComponent]

            public init(group: PathComponent...) {
                self.group = group
            }

            public init() {
                self.group = ["oauth"]
            }
        }

        public struct AccountLinking: Sendable {

            public enum Strategy: Sendable {
                case disabled
                case automatic(allowed: [Identifier.Kind])
                case manual(allowed: [Identifier.Kind])
            }

            public let strategy: Strategy

            public init(strategy: Strategy) {
                self.strategy = strategy
            }
        }

        public let routes: Routes
        public let providers: [Passage.FederatedLogin.Provider]
        public let redirectLocation: String
        public let accountLinking: AccountLinking

        public init(
            routes: Routes = .init(),
            providers: [Passage.FederatedLogin.Provider],
            accountLinking: AccountLinking = .init(strategy: .disabled),
            redirectLocation: String = "/"
        ) {
            self.routes = routes
            self.providers = providers
            self.accountLinking = accountLinking
            self.redirectLocation = redirectLocation
        }
    }

}

// MARK: - Federated Login Path Helpers

public extension Passage.Configuration.FederatedLogin {
    func loginPath(for provider: Passage.FederatedLogin.Provider) -> [PathComponent] {
        return routes.group + provider.routes.login.path
    }
    func callbackPath(for provider: Passage.FederatedLogin.Provider) -> [PathComponent] {
        return routes.group + provider.routes.callback.path
    }
}

// MARK: - Account Linking Strategy Convenience Initializers

public extension Passage.Configuration.FederatedLogin.AccountLinking.Strategy {

    static func automatic(allowed identifiers: Identifier.Kind...) -> Self {
        return .automatic(allowed: identifiers)
    }

    static func manual(allowed identifiers: Identifier.Kind...) -> Self {
        return .manual(allowed: identifiers)
    }

}
