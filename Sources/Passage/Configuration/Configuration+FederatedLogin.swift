import Foundation
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
                self.group = ["connect"]
            }
        }

        public struct AccountLinking: Sendable {

            public enum Strategy: Sendable {
                case disabled
                case automatic(allowed: [Identifier.Kind], fallbackToManualOnMultipleMatches: Bool)
                case manual(allowed: [Identifier.Kind])
            }

            public struct Routes: Sendable {
                public let select: [PathComponent]
                public let verify: [PathComponent]

                public init(
                    select: [PathComponent] = ["link", "select"],
                    verify: [PathComponent] = ["link", "verify"]
                ) {
                    self.select = select
                    self.verify = verify
                }
            }

            public let strategy: Strategy
            public let stateExpiration: TimeInterval
            public let routes: Routes

            public init(
                strategy: Strategy,
                stateExpiration: TimeInterval = 600,
                routes: Routes = .init()
            ) {
                self.strategy = strategy
                self.stateExpiration = stateExpiration
                self.routes = routes
            }

            var enabled: Bool {
                switch strategy {
                case .disabled:
                    return false
                case .automatic, .manual:
                    return true
                }
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
    var linkSelectPath: [PathComponent] {
        return routes.group + accountLinking.routes.select
    }
    var linkVerifyPath: [PathComponent] {
        return routes.group + accountLinking.routes.verify
    }
}
