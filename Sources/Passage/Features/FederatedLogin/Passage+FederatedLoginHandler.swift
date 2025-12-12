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
                config: configuration.oauth,
            ) { (request, identity) in
                let user = try await request.federated.login(
                    identity: identity,
                )

                // Store tokens in session if using session auth
                if request.hasSession {
                    request.session.data["access_token"] = user.accessToken
                    request.session.data["refresh_token"] = user.refreshToken
                }

                return request.redirect(to: configuration.oauth.redirectLocation)
            }
        }
    }

}
