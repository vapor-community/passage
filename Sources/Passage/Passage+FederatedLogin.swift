import Vapor

extension Passage {

    struct FederatedLogin: Sendable {

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
        }
    }

    var oauth: FederatedLogin {
        FederatedLogin(
            app: app
        )
    }

}

extension Passage.FederatedLogin {

    var service: (any Passage.FederatedLoginService)? {
        app.passage.storage.services.federatedLogin
    }
}

// MARK: - Federated Login Service

public extension Passage {

    protocol FederatedLoginService: Sendable {

        func register(
            router: any RoutesBuilder,
            origin: URL,
            group: [PathComponent],
            config: Passage.Configuration.FederatedLogin,
            completion: @escaping @Sendable (
                _ provider: Passage.Configuration.FederatedLogin.Provider,
                _ request: Request,
                _ payload: String
            ) async throws -> some AsyncResponseEncodable
        ) throws
    }

}

