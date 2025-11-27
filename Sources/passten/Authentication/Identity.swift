//
//  Identity.swift
//  passten
//
//  Created by Max Rozdobudko on 11/6/25.
//

import Vapor
import JWT
import struct NIOConcurrencyHelpers.NIOLock
import NIOCore
import NIOPosix

final class Identity: @unchecked Sendable {

    init(app: Application) {
        self.app = app
        self.lock = .init()
    }

    private let app: Application

    private let lock: NIOLock

    // MARK: - Configuration State

    private var _store: (any Store)?
    private var _tokens: Configuration.Tokens = .init()
    private var _random: (any RandomGenerator) = DefaultRandomGenerator()

    // MARK: - Accessors

    var store: any Store {
        get throws {
            guard let store = lock.withLock({ _store }) else {
                throw IdentityError.storeNotConfigured
            }
            return store
        }
    }

    var tokens: Configuration.Tokens {
        lock.withLock { _tokens }
    }

    var random: any RandomGenerator {
        lock.withLock { _random }
    }

    // MARK: - Configuration

    func configure(
        jwks: Configuration.JWKS,
        store: any Store,
        routes: Routes = .init(),
        tokens: Configuration.Tokens = .init(),
        random: any RandomGenerator = DefaultRandomGenerator()
    ) async throws {
        lock.withLockVoid {
            self._store = store
            self._tokens = tokens
            self._random = random
        }

        try await app.jwt.keys.add(jwksJSON: jwks.json)

        try app.register(collection: IdentityRouteCollection(routes: routes))
    }

}

// MARK: - Store

extension Identity {

    protocol Store {
        var users: any UserStore { get }
        var tokens: any TokenStore { get }
    }

    protocol UserStore {
        func create(with credential: Credential) async throws
        func find(byId id: String) async throws -> (any User)?
        func find(byCredential credential: Credential) async throws -> (any User)?
        func find(byIdentifier identifier: Identifier) async throws -> (any User)?
    }

    protocol TokenStore {
        @discardableResult
        func createRefreshToken(
            for user: any User,
            tokenHash hash: String,
            expiresAt: Date,
        ) async throws -> any RefreshToken

        @discardableResult
        func createRefreshToken(
            for user: any User,
            tokenHash hash: String,
            expiresAt: Date,
            replacing tokenToReplace: (any RefreshToken)?
        ) async throws -> any RefreshToken

        func find(refreshTokenHash hash: String) async throws -> (any RefreshToken)?
        func revokeRefreshToken(for user: any User) async throws
        func revokeRefreshToken(withHash hash: String) async throws
        func revoke(refreshTokenFamilyStartingFrom token: any RefreshToken) async throws
    }

}


// MARK: - Route

extension Identity {

    struct Routes: Sendable {
        struct Register {
            static let `default` = Register(path: "register")
            let path: [PathComponent]
            init(path: PathComponent...) {
                self.path = path
            }
        }

        struct Login {
            static let `default` = Login(path: "login")
            let path: [PathComponent]
            init(path: PathComponent...) {
                self.path = path
            }
        }

        struct Logout {
            static let `default` = Logout(path: "logout")
            let path: [PathComponent]
            init(path: PathComponent...) {
                self.path = path
            }
        }

        struct RefreshToken {
            static let `default` = RefreshToken(path: "refresh-token")
            let path: [PathComponent]
            init(path: PathComponent...) {
                self.path = path
            }
        }

        struct CurrentUser {
            static let `default` = CurrentUser(path: "me")
            let path: [PathComponent]
            init(path: PathComponent...) {
                self.path = path
            }
        }

        private init(
            group: [PathComponent],
            register: Register,
            login: Login,
            logout: Logout,
            refreshToken: RefreshToken,
            currentUser: CurrentUser,
        ) {
            self.group = group
            self.register = register
            self.login = login
            self.logout = logout
            self.refreshToken = refreshToken
            self.currentUser = currentUser
        }

        init(
            group: PathComponent...,
            register: Register         = .default,
            login: Login               = .default,
            logout: Logout             = .default,
            refreshToken: RefreshToken = .default,
            currentUser: CurrentUser   = .default,
        ) {
            self.init(
                group: group,
                register: register,
                login: login,
                logout: logout,
                refreshToken: refreshToken,
                currentUser: currentUser
            )
        }

        init(
            register: Register         = .default,
            login: Login               = .default,
            logout: Logout             = .default,
            refreshToken: RefreshToken = .default,
            currentUser: CurrentUser   = .default,
        ) {
            self.init(
                group: ["auth"],
                register: register,
                login: login,
                logout: logout,
                refreshToken: refreshToken,
                currentUser: currentUser
            )
        }

        let group: [PathComponent]
        let register: Register
        let login: Login
        let logout: Logout
        let refreshToken: RefreshToken
        let currentUser: CurrentUser
    }
}

// MARK: - Random

extension Identity {
    protocol RandomGenerator {
        func generateRandomString(count: Int) -> String
        func generateOpaqueToken() -> String
        func hashOpaqueToken(token: String) -> String
    }
}

struct DefaultRandomGenerator: Identity.RandomGenerator {
    func generateRandomString(count: Int) -> String {
        Data([UInt8].random(count: count)).base64EncodedString()
    }
    func generateOpaqueToken() -> String {
        generateRandomString(count: 32)
    }
    func hashOpaqueToken(token: String) -> String {
        SHA256.hash(data: Data(token.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}



// MARK: - Application Storage

extension Identity {
    struct Key: StorageKey {
        typealias Value = Identity
    }
}

extension Application {

    var identity: Identity {
        if let identity = storage[Identity.Key.self] {
            return identity
        }
        let identity = Identity(app: self)
        storage[Identity.Key.self] = identity
        return identity
    }

}

extension Request {

    var store: any Identity.Store {
        get throws {
            try application.identity.store
        }
    }

    var tokens: Identity.Configuration.Tokens {
        application.identity.tokens
    }

    var random: any Identity.RandomGenerator {
        application.identity.random
    }
}
