import Vapor

extension Passage {

    public struct FederatedLogin: Sendable {

        let app: Application

        func register(
            config: Passage.Configuration,
        ) throws {
            try service?.register(
                router: app,
                origin: config.origin,
                group: config.routes.group,
                config: config.oauth,
            ) { provider, request, tokens in
                print(">>> \(tokens)")
                // TODO: Entry Point for handling federated login callback
                // merge or create user, issue Passage access token, etc.
                return request.redirect(to: config.oauth.redirectLocation)
            }

            try service?.register(
                router: app,
                origin: config.origin,
                config: config.oauth,
            ) { [weak self] (request, provider, identifier, info) in

            }
        }
    }

    var oauth: FederatedLogin {
        FederatedLogin(
            app: app
        )
    }

}

// MARK: - Service Accessor

extension Passage.FederatedLogin {

    var service: (any Passage.FederatedLoginService)? {
        app.passage.storage.services.federatedLogin
    }
}

// MARK: -

extension Passage.FederatedLogin {

    func signIn(
        with provider: Provider,
        identifier: Identifier,
    ) async throws -> Void {
    }

}
