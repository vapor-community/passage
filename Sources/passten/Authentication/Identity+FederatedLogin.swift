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
            group: [PathComponent],
            config: Identity.Configuration.FederatedLogin,
        ) throws {
            try service?.register(
                router: app,
                group: group,
                config: config,
            ) { provider, request, payload in
                request.redirect(to: "/")
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

