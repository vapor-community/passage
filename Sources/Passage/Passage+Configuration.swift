import Foundation
import Vapor

public extension Passage {

    public struct Configuration: Sendable {
        let origin: URL
        let routes: Routes
        let tokens: Tokens
        let jwt: JWT
        let verification: Verification
        let restoration: Restoration
        let oauth: FederatedLogin

        public init(
            origin: URL,
            routes: Routes = .init(),
            tokens: Tokens = .init(),
            jwt: JWT? = nil,
            verification: Verification = .init(),
            restoration: Restoration = .init(),
            oauth: FederatedLogin = .init(routes: .init(), providers: [])
        ) throws {
            self.origin = origin
            self.routes = routes
            self.tokens = tokens
            self.jwt = try jwt ?? JWT(jwks: try .fileFromEnvironment())
            self.verification = verification
            self.restoration = restoration
            self.oauth = oauth
        }
    }

}

// MARK: - Routes

extension Passage.Configuration {
    public struct Routes: Sendable {
        public struct Register: Sendable {
            public static let `default` = Register(path: "register")
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        public struct Login: Sendable {
            public static let `default` = Login(path: "login")
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        public struct Logout: Sendable {
            public static let `default` = Logout(path: "logout")
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        public struct RefreshToken: Sendable {
            public static let `default` = RefreshToken(path: "refresh-token")
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        public struct CurrentUser: Sendable {
            public static let `default` = CurrentUser(path: "me")
            let path: [PathComponent]
            public init(path: PathComponent...) {
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

        public init(
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

        public init(
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

extension Passage.Configuration {

    public struct Tokens: Sendable {

        public struct IdToken: Sendable {
            let timeToLive: TimeInterval
            public init(timeToLive: TimeInterval) {
                self.timeToLive = timeToLive
            }
        }

        public struct AccessToken: Sendable {
            let timeToLive: TimeInterval
            public init(timeToLive: TimeInterval) {
                self.timeToLive = timeToLive
            }
        }

        public struct RefreshToken: Sendable {
            let timeToLive: TimeInterval
            public init(timeToLive: TimeInterval) {
                self.timeToLive = timeToLive
            }
        }

        let issuer: String?

        let idToken: IdToken
        let accessToken: AccessToken
        let refreshToken: RefreshToken

        public init(
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

public extension Passage.Configuration {

    public struct JWT: Sendable {
        public struct JWKS: Sendable {
            let json: String
            public init(json: String) {
                self.json = json
            }
        }

        let jwks: JWKS

        public init(jwks: JWKS) {
            self.jwks = jwks
        }
    }

}

public extension Passage.Configuration.JWT.JWKS {

    static func environment(name: String = "JWKS") throws -> Self {
        guard let json = ProcessInfo.processInfo.environment[name] else {
            throw PassageError.missingEnvironmentVariable(name: name)
        }
        return .init(json: json)
    }

    static func file(path: String) throws -> Self {
        let json = try String(contentsOfFile: path, encoding: .utf8)
        return .init(json: json)
    }

    static func fileFromEnvironment(name: String = "JWKS_FILE_PATH") throws -> Self {
        guard let path = ProcessInfo.processInfo.environment[name] else {
            throw PassageError.missingEnvironmentVariable(name: name)
        }
        return try .file(path: path)
    }

}

// MARK: - Verification

extension Passage.Configuration {

    public struct Verification: Sendable {

        let email: Email
        let phone: Phone
        let useQueues: Bool

        public init(
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

extension Passage.Configuration.Verification {

    public struct Email: Sendable {
        let routes: Routes
        let codeLength: Int
        let codeExpiration: TimeInterval
        let maxAttempts: Int

        // MARK: - Routes

        public struct Routes: Sendable {

            public struct Verify: Sendable {
                public static let `default` = Verify(path: "email", "verify")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Resend: Sendable {
                public static let `default` = Resend(path: "email", "resend")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            let verify: Verify
            let resend: Resend

            public init(
                verify: Verify = .default,
                resend: Resend = .default
            ) {
                self.verify = verify
                self.resend = resend
            }
        }

        public init(
            routes: Routes = .init(),
            codeLength: Int = 6,
            codeExpiration: TimeInterval = 15 * 60,
            maxAttempts: Int = 3,
        ) {
            self.routes = routes
            self.codeLength = codeLength
            self.codeExpiration = codeExpiration
            self.maxAttempts = maxAttempts
        }
    }

}

extension Passage.Configuration {

    var emailVerificationURL: URL {
        origin.appending(path: (routes.group + verification.email.routes.verify.path).string)
    }

}

// MARK: - Verification.Phone

extension Passage.Configuration.Verification {

    public struct Phone: Sendable {
        let routes: Routes
        let codeLength: Int
        let codeExpiration: TimeInterval
        let maxAttempts: Int

        public struct Routes: Sendable {
            public struct SendCode: Sendable {
                public static let `default` = SendCode(path: "phone", "send-code")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Verify: Sendable {
                public static let `default` = Verify(path: "phone", "verify")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Resend: Sendable {
                public static let `default` = Resend(path: "phone", "resend")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            let sendCode: SendCode
            let verify: Verify
            let resend: Resend

            public init(
                sendCode: SendCode = .default,
                verify: Verify = .default,
                resend: Resend = .default
            ) {
                self.sendCode = sendCode
                self.verify = verify
                self.resend = resend
            }
        }

        public init(
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

extension Passage.Configuration {

    var phoneVerificationURL: URL {
        origin.appending(path: (routes.group + verification.phone.routes.verify.path).string)
    }

}

// MARK: - Restoration (Password Reset)

extension Passage.Configuration {

    public struct Restoration: Sendable {

        /// Preferred delivery channel for password reset when user is looked up by username
        public enum PreferredDelivery: Sendable {
            case email
            case phone
        }

        let preferredDelivery: PreferredDelivery
        let email: Email
        let phone: Phone
        let useQueues: Bool

        public init(
            preferredDelivery: PreferredDelivery = .email,
            email: Email = .init(),
            phone: Phone = .init(),
            useQueues: Bool = false
        ) {
            self.preferredDelivery = preferredDelivery
            self.email = email
            self.phone = phone
            self.useQueues = useQueues
        }
    }

}

// MARK: - Restoration.Email

extension Passage.Configuration.Restoration {

    public struct Email: Sendable {

        public struct Routes: Sendable {

            public struct Request: Sendable {
                public static let `default` = Request(path: "password", "reset", "email")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Verify: Sendable {
                public static let `default` = Verify(path: "password", "reset", "email", "verify")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Resend: Sendable {
                public static let `default` = Resend(path: "password", "reset", "email", "resend")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            let request: Request
            let verify: Verify
            let resend: Resend

            public init(
                request: Request = .default,
                verify: Verify = .default,
                resend: Resend = .default
            ) {
                self.request = request
                self.verify = verify
                self.resend = resend
            }
        }

        public struct WebForm: Sendable {

            public struct Route: Sendable {
                public static let `default` = Route(path: "password", "reset")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
                public init(path: [PathComponent]) {
                    self.path = path
                }
            }

            public static let `default` = WebForm(
                enabled: true,
                template: "password-reset-form",
                route: .default
            )

            let enabled: Bool
            let template: String
            let route: Route

            public init(
                enabled: Bool = true,
                template: String = "password-reset-form",
                route: Route = .default
            ) {
                self.enabled = enabled
                self.template = template
                self.route = route
            }
        }

        let routes: Routes
        let codeLength: Int
        let codeExpiration: TimeInterval
        let maxAttempts: Int
        let resetLinkBaseURL: URL?
        let webForm: WebForm

        public init(
            routes: Routes = .init(),
            codeLength: Int = 6,
            codeExpiration: TimeInterval = 15 * 60,  // 15 minutes
            maxAttempts: Int = 3,
            resetLinkBaseURL: URL? = nil,
            webForm: WebForm = .default
        ) {
            self.routes = routes
            self.codeLength = codeLength
            self.codeExpiration = codeExpiration
            self.maxAttempts = maxAttempts
            self.resetLinkBaseURL = resetLinkBaseURL
            self.webForm = webForm
        }
    }

}

extension Passage.Configuration {

    var emailPasswordResetURL: URL {
        origin.appending(path: (routes.group + restoration.email.routes.verify.path).string)
    }

    var emailPasswordResetFormURL: URL {
        origin.appending(path: (routes.group + restoration.email.webForm.route.path).string)
    }

    /// URL for password reset link in email.
    /// If resetLinkBaseURL is set, uses that; otherwise uses the web form route if enabled,
    /// or falls back to the API verify endpoint.
    func emailPasswordResetLinkURL(code: String, email: String) -> URL {
        let baseURL: URL
        if let customURL = restoration.email.resetLinkBaseURL {
            baseURL = customURL
        } else if restoration.email.webForm.enabled {
            baseURL = emailPasswordResetFormURL
        } else {
            baseURL = emailPasswordResetURL
        }

        return baseURL.appending(queryItems: [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "email", value: email)
        ])
    }

}

// MARK: - Restoration.Phone

extension Passage.Configuration.Restoration {

    public struct Phone: Sendable {
        let routes: Routes
        let codeLength: Int
        let codeExpiration: TimeInterval
        let maxAttempts: Int

        public struct Routes: Sendable {

            public struct Request: Sendable {
                public static let `default` = Request(path: "password", "reset", "phone")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Verify: Sendable {
                public static let `default` = Verify(path: "password", "reset", "phone", "verify")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Resend: Sendable {
                public static let `default` = Resend(path: "password", "reset", "phone", "resend")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            let request: Request
            let verify: Verify
            let resend: Resend

            public init(
                request: Request = .default,
                verify: Verify = .default,
                resend: Resend = .default
            ) {
                self.request = request
                self.verify = verify
                self.resend = resend
            }
        }

        public init(
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

extension Passage.Configuration {

    var phonePasswordResetURL: URL {
        origin.appending(path: (routes.group + restoration.phone.routes.verify.path).string)
    }

}

// MARK: - Federated Login

public extension Passage.Configuration {

    public struct FederatedLogin: Sendable {
        public struct Routes: Sendable {
            let group: [PathComponent]

            public init(group: PathComponent...) {
                self.group = group
            }

            public init() {
                self.group = ["oauth"]
            }
        }

        public struct Provider: Sendable {
            public struct Name: Sendable, Codable, Hashable, RawRepresentable {
                public let rawValue: String
                public init(rawValue: String) {
                    self.rawValue = rawValue
                }
            }

            public enum Credentials: Sendable {
                case conventional
                case client(id: String, secret: String)
            }

            public struct Routes: Sendable {
                struct Login: Sendable {
                    let path: [PathComponent]
                    init(path: PathComponent...) {
                        self.path = path
                    }
                    init(path: [PathComponent]) {
                        self.path = path
                    }
                }

                struct Callback: Sendable {
                    let path: [PathComponent]
                    init(path: PathComponent...) {
                        self.path = path
                    }
                    init(path: [PathComponent]) {
                        self.path = path
                    }
                }

                let login: Login
                let callback: Callback

                init(
                    login: Login = .init(),
                    callback: Callback = .init(path: "callback")
                ) {
                    self.login = login
                    self.callback = callback
                }
            }

            public let name: Name
            public let credentials: Credentials
            public let scope: [String]
            public let routes: Routes

            init(
                name: Name,
                credentials: Credentials = .conventional,
                scope: [String] = [],
                routes: Routes? = nil,
            ) {
                self.name = name
                self.credentials = credentials
                self.scope = scope
                self.routes = routes ?? .init(
                    login: .init(path: name.rawValue.pathComponents),
                    callback: .init(path: name.rawValue.pathComponents + ["callback"])
                )

            }
        }

        public let routes: Routes
        public let providers: [Provider]
        public let redirectLocation: String

        public init(
            routes: Routes = .init(),
            providers: [Provider],
            redirectLocation: String = "/"
        ) {
            self.routes = routes
            self.providers = providers
            self.redirectLocation = redirectLocation
        }
    }

}

public extension Passage.Configuration.FederatedLogin {
    func loginPath(for provider: Passage.Configuration.FederatedLogin.Provider) -> [PathComponent] {
        return routes.group + provider.routes.login.path
    }
    func callbackPath(for provider: Passage.Configuration.FederatedLogin.Provider) -> [PathComponent] {
        return routes.group + provider.routes.callback.path
    }
}

public extension Passage.Configuration.FederatedLogin.Provider {

    static func google(
        credentials: Credentials = .conventional,
        scope: [String] = [],
        routes: Routes? = nil,
    ) -> Self {
        .init(
            name: .google,
            credentials: credentials,
            scope: scope,
            routes: routes,
        )
    }

    static func github(
        credentials: Credentials = .conventional,
        scope: [String] = [],
        routes: Routes? = nil,
    ) -> Self {
        .init(
            name: .github,
            credentials: credentials,
            scope: scope,
            routes: routes,
        )
    }

    static func custom(
        name: String,
        credentials: Credentials = .conventional,
        scope: [String] = [],
        routes: Routes? = nil,
    ) -> Self {
        .init(
            name: .init(rawValue: name),
            credentials: credentials,
            scope: scope,
            routes: routes,
        )
    }
}

public extension Passage.Configuration.FederatedLogin.Provider.Name {
    static let google = named("google")
    static let github = named("github")

    static func named(_ name: String) -> Self {
        return Self(rawValue: name)
    }
}
