//
//  Identity+Config.swift
//  passten
//
//  Created by Max Rozdobudko on 11/28/25.
//

import Foundation
import Vapor

extension Identity {

    struct Configuration {
        let routes: Routes
        let tokens: Tokens
        let jwt: JWT
        let verification: Verification

        init(
            routes: Routes = .init(),
            tokens: Tokens = .init(),
            jwt: JWT? = nil,
            verification: Verification = .init(),
        ) throws {
            self.routes = routes
            self.tokens = tokens
            self.jwt = try jwt ?? JWT(jwks: try .fileFromEnvironment())
            self.verification = verification
        }
    }

}

// MARK: - Routes

extension Identity.Configuration {
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

// MARK: - Tokens

extension Identity.Configuration {

    struct Tokens: Sendable {

        struct IdToken: Sendable {
            let timeToLive: TimeInterval
        }

        struct AccessToken: Sendable {
            let timeToLive: TimeInterval
        }

        struct RefreshToken: Sendable {
            let timeToLive: TimeInterval
        }

        let issuer: String?

        let idToken: IdToken
        let accessToken: AccessToken
        let refreshToken: RefreshToken

        init(
            issuer: String? = nil,
            idToken: IdToken = .init(timeToLive: 1 * 3600),
            accessToken: AccessToken = .init(timeToLive: 15 * 60),
            refreshToken: RefreshToken = .init(timeToLive: 7 * 24 * 3600),
        ) {
            self.issuer = issuer
            self.idToken = idToken
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
    }

}

// MARK: - JWKS

extension Identity.Configuration {

    struct JWT: Sendable {
        struct JWKS: Sendable {
            let json: String
        }

        let jwks: JWKS
    }

}

extension Identity.Configuration.JWT.JWKS {

    static func environment(name: String = "JWKS") throws -> Self {
        guard let json = ProcessInfo.processInfo.environment[name] else {
            throw IdentityError.missingEnvironmentVariable(name: name)
        }
        return .init(json: json)
    }

    static func file(path: String) throws -> Self {
        let json = try String(contentsOfFile: path, encoding: .utf8)
        return .init(json: json)
    }

    static func fileFromEnvironment(name: String = "JWKS_FILE_PATH") throws -> Self {
        guard let path = ProcessInfo.processInfo.environment[name] else {
            throw IdentityError.missingEnvironmentVariable(name: name)
        }
        return try .file(path: path)
    }

}

// MARK: - Verification

extension Identity.Configuration {

    struct Verification: Sendable {

        let email: Email
        let phone: Phone
        let useQueues: Bool

        init(
            email: Email = .init(),
            phone: Phone = .init(),
            useQueues: Bool = false
        ) {
            self.email = email
            self.phone = phone
            self.useQueues = useQueues
        }
    }

}

// MARK: - Verification.Email

extension Identity.Configuration.Verification {

    struct Email: Sendable {
        let routes: Routes
        let codeLength: Int
        let codeExpiration: TimeInterval
        let maxAttempts: Int

        struct Routes: Sendable {
            struct SendCode: Sendable {
                static let `default` = SendCode(path: "email", "send-code")
                let path: [PathComponent]
                init(path: PathComponent...) {
                    self.path = path
                }
            }

            struct Verify: Sendable {
                static let `default` = Verify(path: "email", "verify")
                let path: [PathComponent]
                init(path: PathComponent...) {
                    self.path = path
                }
            }

            struct Resend: Sendable {
                static let `default` = Resend(path: "email", "resend")
                let path: [PathComponent]
                init(path: PathComponent...) {
                    self.path = path
                }
            }

            let sendCode: SendCode
            let verify: Verify
            let resend: Resend

            init(
                sendCode: SendCode = .default,
                verify: Verify = .default,
                resend: Resend = .default
            ) {
                self.sendCode = sendCode
                self.verify = verify
                self.resend = resend
            }
        }

        init(
            routes: Routes = .init(),
            codeLength: Int = 6,
            codeExpiration: TimeInterval = 15 * 60,
            maxAttempts: Int = 3
        ) {
            self.routes = routes
            self.codeLength = codeLength
            self.codeExpiration = codeExpiration
            self.maxAttempts = maxAttempts
        }
    }

}

// MARK: - Verification.Phone

extension Identity.Configuration.Verification {

    struct Phone: Sendable {
        let routes: Routes
        let codeLength: Int
        let codeExpiration: TimeInterval
        let maxAttempts: Int

        struct Routes: Sendable {
            struct SendCode: Sendable {
                static let `default` = SendCode(path: "phone", "send-code")
                let path: [PathComponent]
                init(path: PathComponent...) {
                    self.path = path
                }
            }

            struct Verify: Sendable {
                static let `default` = Verify(path: "phone", "verify")
                let path: [PathComponent]
                init(path: PathComponent...) {
                    self.path = path
                }
            }

            struct Resend: Sendable {
                static let `default` = Resend(path: "phone", "resend")
                let path: [PathComponent]
                init(path: PathComponent...) {
                    self.path = path
                }
            }

            let sendCode: SendCode
            let verify: Verify
            let resend: Resend

            init(
                sendCode: SendCode = .default,
                verify: Verify = .default,
                resend: Resend = .default
            ) {
                self.sendCode = sendCode
                self.verify = verify
                self.resend = resend
            }
        }

        init(
            routes: Routes = .init(),
            codeLength: Int = 6,
            codeExpiration: TimeInterval = 5 * 60,  // 5 minutes for SMS
            maxAttempts: Int = 3
        ) {
            self.routes = routes
            self.codeLength = codeLength
            self.codeExpiration = codeExpiration
            self.maxAttempts = maxAttempts
        }
    }

}
