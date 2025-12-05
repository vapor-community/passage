import Testing
import Vapor
@testable import Passage

@Suite("FederatedLogin Provider Tests")
struct FederatedLoginProviderTests {

    // MARK: - Provider Name Tests

    @Test("Provider Name initialization with rawValue")
    func providerNameInitialization() {
        let name = Passage.FederatedLogin.Provider.Name(rawValue: "custom")
        #expect(name.rawValue == "custom")
    }

    @Test("Provider Name google static member")
    func providerNameGoogle() {
        let google = Passage.FederatedLogin.Provider.Name.google
        #expect(google.rawValue == "google")
    }

    @Test("Provider Name github static member")
    func providerNameGithub() {
        let github = Passage.FederatedLogin.Provider.Name.github
        #expect(github.rawValue == "github")
    }

    @Test("Provider Name named factory method")
    func providerNameNamed() {
        let name = Passage.FederatedLogin.Provider.Name.named("custom-provider")
        #expect(name.rawValue == "custom-provider")
    }

    @Test("Provider Name conforms to Codable")
    func providerNameCodable() throws {
        let name = Passage.FederatedLogin.Provider.Name(rawValue: "test")

        let encoder = JSONEncoder()
        let data = try encoder.encode(name)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Passage.FederatedLogin.Provider.Name.self, from: data)

        #expect(decoded.rawValue == name.rawValue)
    }

    @Test("Provider Name conforms to Hashable")
    func providerNameHashable() {
        let name1 = Passage.FederatedLogin.Provider.Name(rawValue: "test")
        let name2 = Passage.FederatedLogin.Provider.Name(rawValue: "test")
        let name3 = Passage.FederatedLogin.Provider.Name(rawValue: "different")

        #expect(name1 == name2)
        #expect(name1 != name3)

        var set = Set<Passage.FederatedLogin.Provider.Name>()
        set.insert(name1)
        set.insert(name2)

        #expect(set.count == 1)
    }

    @Test("Provider Name conforms to Sendable")
    func providerNameSendable() {
        let _: any Sendable.Type = Passage.FederatedLogin.Provider.Name.self
        #expect(Passage.FederatedLogin.Provider.Name.self is Sendable.Type)
    }

    // MARK: - Provider Credentials Tests

    @Test("Provider Credentials conventional case")
    func credentialsConventional() {
        let credentials = Passage.FederatedLogin.Provider.Credentials.conventional

        if case .conventional = credentials {
            // Success
        } else {
            Issue.record("Expected conventional credentials")
        }
    }

    @Test("Provider Credentials client case")
    func credentialsClient() {
        let credentials = Passage.FederatedLogin.Provider.Credentials.client(
            id: "client-id",
            secret: "client-secret"
        )

        if case .client(let id, let secret) = credentials {
            #expect(id == "client-id")
            #expect(secret == "client-secret")
        } else {
            Issue.record("Expected client credentials")
        }
    }

    @Test("Provider Credentials conforms to Sendable")
    func credentialsSendable() {
        let _: any Sendable.Type = Passage.FederatedLogin.Provider.Credentials.self
        #expect(Passage.FederatedLogin.Provider.Credentials.self is Sendable.Type)
    }

    // MARK: - Provider Routes Tests

    @Test("Provider Routes Login initialization with variadic path")
    func routesLoginVariadic() {
        let login = Passage.FederatedLogin.Provider.Routes.Login(path: "oauth", "google")
        #expect(login.path.count == 2)
    }

    @Test("Provider Routes Login initialization with array path")
    func routesLoginArray() {
        let path: [PathComponent] = ["oauth", "google"]
        let login = Passage.FederatedLogin.Provider.Routes.Login(path: path)
        #expect(login.path.count == 2)
    }

    @Test("Provider Routes Callback initialization with variadic path")
    func routesCallbackVariadic() {
        let callback = Passage.FederatedLogin.Provider.Routes.Callback(path: "oauth", "callback")
        #expect(callback.path.count == 2)
    }

    @Test("Provider Routes Callback initialization with array path")
    func routesCallbackArray() {
        let path: [PathComponent] = ["oauth", "callback"]
        let callback = Passage.FederatedLogin.Provider.Routes.Callback(path: path)
        #expect(callback.path.count == 2)
    }

    @Test("Provider Routes default initialization")
    func routesDefaultInitialization() {
        let routes = Passage.FederatedLogin.Provider.Routes()

        #expect(routes.login.path.isEmpty)
        #expect(routes.callback.path == ["callback"])
    }

    @Test("Provider Routes custom initialization")
    func routesCustomInitialization() {
        let login = Passage.FederatedLogin.Provider.Routes.Login(path: "auth", "login")
        let callback = Passage.FederatedLogin.Provider.Routes.Callback(path: "auth", "callback")
        let routes = Passage.FederatedLogin.Provider.Routes(login: login, callback: callback)

        #expect(routes.login.path == ["auth", "login"])
        #expect(routes.callback.path == ["auth", "callback"])
    }

    @Test("Provider Routes conforms to Sendable")
    func routesSendable() {
        let _: any Sendable.Type = Passage.FederatedLogin.Provider.Routes.self
        #expect(Passage.FederatedLogin.Provider.Routes.self is Sendable.Type)
    }

    // MARK: - Provider Initialization Tests

    @Test("Provider initialization with all parameters")
    func providerInitialization() {
        let name = Passage.FederatedLogin.Provider.Name(rawValue: "google")
        let credentials = Passage.FederatedLogin.Provider.Credentials.client(id: "id", secret: "secret")
        let scope = ["email", "profile"]
        let login = Passage.FederatedLogin.Provider.Routes.Login(path: "google")
        let callback = Passage.FederatedLogin.Provider.Routes.Callback(path: "google", "callback")
        let routes = Passage.FederatedLogin.Provider.Routes(login: login, callback: callback)

        let provider = Passage.FederatedLogin.Provider(
            name: name,
            credentials: credentials,
            scope: scope,
            routes: routes
        )

        #expect(provider.name.rawValue == "google")
        #expect(provider.scope == ["email", "profile"])
    }

    @Test("Provider initialization with default routes generates correct paths")
    func providerDefaultRoutes() {
        let name = Passage.FederatedLogin.Provider.Name(rawValue: "github")
        let provider = Passage.FederatedLogin.Provider(name: name)

        #expect(provider.routes.login.path == ["github"])
        #expect(provider.routes.callback.path == ["github", "callback"])
    }

    @Test("Provider initialization with conventional credentials")
    func providerConventionalCredentials() {
        let name = Passage.FederatedLogin.Provider.Name.google
        let provider = Passage.FederatedLogin.Provider(name: name)

        if case .conventional = provider.credentials {
            // Success
        } else {
            Issue.record("Expected conventional credentials by default")
        }
    }

    @Test("Provider initialization with empty scope")
    func providerEmptyScope() {
        let name = Passage.FederatedLogin.Provider.Name.google
        let provider = Passage.FederatedLogin.Provider(name: name)

        #expect(provider.scope.isEmpty)
    }

    // MARK: - Provider Convenience Initializers Tests

    @Test("Provider google() convenience initializer")
    func googleConvenienceInitializer() {
        let provider = Passage.FederatedLogin.Provider.google()

        #expect(provider.name.rawValue == "google")
        #expect(provider.scope.isEmpty)
    }

    @Test("Provider google() with credentials")
    func googleWithCredentials() {
        let credentials = Passage.FederatedLogin.Provider.Credentials.client(id: "google-id", secret: "google-secret")
        let provider = Passage.FederatedLogin.Provider.google(credentials: credentials)

        if case .client(let id, let secret) = provider.credentials {
            #expect(id == "google-id")
            #expect(secret == "google-secret")
        } else {
            Issue.record("Expected client credentials")
        }
    }

    @Test("Provider google() with scope")
    func googleWithScope() {
        let provider = Passage.FederatedLogin.Provider.google(scope: ["email", "profile"])

        #expect(provider.scope == ["email", "profile"])
    }

    @Test("Provider google() with custom routes")
    func googleWithCustomRoutes() {
        let login = Passage.FederatedLogin.Provider.Routes.Login(path: "auth", "google")
        let callback = Passage.FederatedLogin.Provider.Routes.Callback(path: "auth", "google", "callback")
        let routes = Passage.FederatedLogin.Provider.Routes(login: login, callback: callback)

        let provider = Passage.FederatedLogin.Provider.google(routes: routes)

        #expect(provider.routes.login.path == ["auth", "google"])
        #expect(provider.routes.callback.path == ["auth", "google", "callback"])
    }

    @Test("Provider github() convenience initializer")
    func githubConvenienceInitializer() {
        let provider = Passage.FederatedLogin.Provider.github()

        #expect(provider.name.rawValue == "github")
        #expect(provider.scope.isEmpty)
    }

    @Test("Provider github() with credentials")
    func githubWithCredentials() {
        let credentials = Passage.FederatedLogin.Provider.Credentials.client(id: "github-id", secret: "github-secret")
        let provider = Passage.FederatedLogin.Provider.github(credentials: credentials)

        if case .client(let id, let secret) = provider.credentials {
            #expect(id == "github-id")
            #expect(secret == "github-secret")
        } else {
            Issue.record("Expected client credentials")
        }
    }

    @Test("Provider github() with scope")
    func githubWithScope() {
        let provider = Passage.FederatedLogin.Provider.github(scope: ["user:email", "read:user"])

        #expect(provider.scope == ["user:email", "read:user"])
    }

    @Test("Provider custom() convenience initializer")
    func customConvenienceInitializer() {
        let provider = Passage.FederatedLogin.Provider.custom(name: "custom-oauth")

        #expect(provider.name.rawValue == "custom-oauth")
    }

    @Test("Provider custom() with all parameters")
    func customWithAllParameters() {
        let credentials = Passage.FederatedLogin.Provider.Credentials.client(id: "custom-id", secret: "custom-secret")
        let login = Passage.FederatedLogin.Provider.Routes.Login(path: "oauth", "custom")
        let callback = Passage.FederatedLogin.Provider.Routes.Callback(path: "oauth", "custom", "callback")
        let routes = Passage.FederatedLogin.Provider.Routes(login: login, callback: callback)

        let provider = Passage.FederatedLogin.Provider.custom(
            name: "custom-provider",
            credentials: credentials,
            scope: ["openid", "profile"],
            routes: routes
        )

        #expect(provider.name.rawValue == "custom-provider")
        #expect(provider.scope == ["openid", "profile"])
        #expect(provider.routes.login.path == ["oauth", "custom"])
        #expect(provider.routes.callback.path == ["oauth", "custom", "callback"])
    }

    // MARK: - Multiple Providers Tests

    @Test("Multiple providers can coexist")
    func multipleProviders() {
        let google = Passage.FederatedLogin.Provider.google(scope: ["email"])
        let github = Passage.FederatedLogin.Provider.github(scope: ["user"])

        #expect(google.name.rawValue == "google")
        #expect(github.name.rawValue == "github")
        #expect(google.scope != github.scope)
    }

    @Test("Provider instances are independent")
    func providerInstancesIndependent() {
        let provider1 = Passage.FederatedLogin.Provider.google(scope: ["email"])
        let provider2 = Passage.FederatedLogin.Provider.google(scope: ["profile"])

        #expect(provider1.scope != provider2.scope)
    }

    // MARK: - Path Component Conversion Tests

    @Test("Provider name pathComponents conversion")
    func providerNamePathComponents() {
        let name = Passage.FederatedLogin.Provider.Name(rawValue: "google")
        let provider = Passage.FederatedLogin.Provider(name: name)

        // Default routes should use name as path
        #expect(provider.routes.login.path == ["google"])
    }

    @Test("Provider with multi-segment name")
    func providerMultiSegmentName() {
        let name = Passage.FederatedLogin.Provider.Name(rawValue: "oauth/provider")
        let provider = Passage.FederatedLogin.Provider(name: name)

        // The rawValue is stored as-is
        #expect(provider.name.rawValue == "oauth/provider")
    }

    // MARK: - Provider Sendable Conformance Tests

    @Test("Provider conforms to Sendable")
    func providerSendable() {
        let _: any Sendable.Type = Passage.FederatedLogin.Provider.self
        #expect(Passage.FederatedLogin.Provider.self is Sendable.Type)
    }
}
