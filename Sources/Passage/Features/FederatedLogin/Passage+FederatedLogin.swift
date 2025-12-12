import Vapor

// MARK: - Federated Login

public extension Passage {

    struct FederatedLogin: Sendable {
        let request: Request
    }

}

// MARK: - Service Accessors

extension Passage.FederatedLogin {

    var store: Passage.Store {
        request.store
    }

    var tokens: Passage.Tokens {
        request.tokens
    }

    var configuration: Passage.Configuration.FederatedLogin {
        request.configuration.oauth
    }

}

extension Request {

    var federated: Passage.FederatedLogin {
        .init(request: self)
    }

}

// MARK: - Sign In

extension Passage.FederatedLogin {

    func login(
        identity: FederatedIdentity
    ) async throws -> AuthUser {
        if let user = try await store.users.find(byIdentifier: identity.identifier) {
            request.passage.login(user)
            return try await request.tokens.issue(for: user)
        }

        let user = try await store.users.create(
            identifier: identity.identifier,
            with: nil
        )
        request.passage.login(user)
        return try await request.tokens.issue(for: user)
    }

}

extension Passage.FederatedLogin {

    func users(for info: any UserInfo) async throws -> [any User] {
        var users: [any User] = []

        if let email = info.email {
            if let user = try await store.users.find(byIdentifier: .email(email)) {
                users.append(user)
            }
        }

        if let phone = info.phone {
            if let user = try await store.users.find(byIdentifier: .phone(phone)) {
                users.append(user)
            }
        }

        return users
    }


}
