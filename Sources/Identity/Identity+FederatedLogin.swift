//
//  Identity+OAuth.swift
//  passten
//
//  Created by Max Rozdobudko on 11/30/25.
//

import Vapor

extension Identity {

    struct FederatedLogin: Sendable {

        let app: Application

        func register(
            config: Identity.Configuration,
        ) throws {
            try service?.register(
                router: app,
                origin: config.origin,
                group: config.routes.group,
                config: config.oauth,
            ) { provider, request, tokens in
                print(">>> \(tokens)")
                // TODO: Entry Point for handling federated login callback
                // merge or create user, issue Identity access token, etc.
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

extension Identity.FederatedLogin {

    var service: (any Identity.FederatedLoginService)? {
        app.identity.storage.services.federatedLogin
    }
}

// MARK: - Federated Login Service

extension Identity {

    protocol FederatedLoginService: Sendable {

        func register(
            router: any RoutesBuilder,
            origin: URL,
            group: [PathComponent],
            config: Identity.Configuration.FederatedLogin,
            completion: @escaping @Sendable (
                _ provider: Identity.Configuration.FederatedLogin.Provider,
                _ request: Request,
                _ payload: String
            ) async throws -> some AsyncResponseEncodable
        ) throws
    }

}

