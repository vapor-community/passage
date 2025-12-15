import Vapor

// MARK: - Federated Login Handler

extension Passage {

    struct FederatedLoginHandler: Sendable {
        let app: Application
        let configuration: Passage.Configuration

        func register() throws {
            guard let service = app.passage.federatedLogin else {
                return
            }

            try service.register(
                router: app,
                origin: configuration.origin,
                group: configuration.routes.group,
                config: configuration.federatedLogin,
            ) { (request, identity) in
                return try await request.federated.login(identity: identity)
            }
        }
    }

}
