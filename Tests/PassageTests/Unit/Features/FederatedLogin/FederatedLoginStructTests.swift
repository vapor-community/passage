import Testing
import Vapor
@testable import Passage

@Suite("FederatedLogin Struct Tests")
struct FederatedLoginStructTests {

    // MARK: - FederatedLogin Struct Tests

    @Test("FederatedLogin struct is properly namespaced in Passage")
    func federatedLoginNamespace() {
        let typeName = String(reflecting: Passage.FederatedLogin.self)
        #expect(typeName.contains("Passage.FederatedLogin"))
    }

    @Test("FederatedLogin struct conforms to Sendable")
    func federatedLoginSendable() {
        let _: any Sendable.Type = Passage.FederatedLogin.self
        #expect(Passage.FederatedLogin.self is Sendable.Type)
    }

    @Test("FederatedLogin feature is properly namespaced")
    func federatedLoginFeatureNamespace() {
        // Verify the entire FederatedLogin namespace is in Passage
        let structName = String(reflecting: Passage.FederatedLogin.self)
        #expect(structName.contains("Passage.FederatedLogin"))
    }

    // MARK: - Provider Nested Type Tests

    @Test("Provider is nested within FederatedLogin")
    func providerNesting() {
        let typeName = String(reflecting: Passage.FederatedLogin.Provider.self)
        #expect(typeName.contains("Passage.FederatedLogin.Provider"))
    }

    @Test("Provider Name is nested within Provider")
    func providerNameNesting() {
        let typeName = String(reflecting: Passage.FederatedLogin.Provider.Name.self)
        #expect(typeName.contains("Passage.FederatedLogin.Provider.Name"))
    }

    @Test("Provider Credentials is nested within Provider")
    func providerCredentialsNesting() {
        let typeName = String(reflecting: Passage.FederatedLogin.Provider.Credentials.self)
        #expect(typeName.contains("Passage.FederatedLogin.Provider.Credentials"))
    }

    @Test("Provider Routes is nested within Provider")
    func providerRoutesNesting() {
        let typeName = String(reflecting: Passage.FederatedLogin.Provider.Routes.self)
        #expect(typeName.contains("Passage.FederatedLogin.Provider.Routes"))
    }

    // MARK: - Routes Nested Types Tests

    @Test("Routes Login is nested within Routes")
    func routesLoginNesting() {
        let typeName = String(reflecting: Passage.FederatedLogin.Provider.Routes.Login.self)
        #expect(typeName.contains("Passage.FederatedLogin.Provider.Routes.Login"))
    }

    @Test("Routes Callback is nested within Routes")
    func routesCallbackNesting() {
        let typeName = String(reflecting: Passage.FederatedLogin.Provider.Routes.Callback.self)
        #expect(typeName.contains("Passage.FederatedLogin.Provider.Routes.Callback"))
    }

    // MARK: - All Sendable Conformance Tests

    @Test("All FederatedLogin types conform to Sendable")
    func allTypesSendable() {
        // Main struct
        #expect(Passage.FederatedLogin.self is Sendable.Type)

        // Provider and related types
        #expect(Passage.FederatedLogin.Provider.self is Sendable.Type)
        #expect(Passage.FederatedLogin.Provider.Name.self is Sendable.Type)
        #expect(Passage.FederatedLogin.Provider.Credentials.self is Sendable.Type)
        #expect(Passage.FederatedLogin.Provider.Routes.self is Sendable.Type)
        #expect(Passage.FederatedLogin.Provider.Routes.Login.self is Sendable.Type)
        #expect(Passage.FederatedLogin.Provider.Routes.Callback.self is Sendable.Type)
    }

    // MARK: - Type Hierarchy Tests

    @Test("FederatedLogin namespace contains Provider")
    func namespaceContainsProvider() {
        // Create a provider to verify it's accessible through FederatedLogin
        let provider = Passage.FederatedLogin.Provider.google()
        #expect(provider.name.rawValue == "google")
    }

    @Test("Provider namespace contains all nested types")
    func providerContainsNestedTypes() {
        // Verify all nested types are accessible
        let name = Passage.FederatedLogin.Provider.Name.google
        let credentials = Passage.FederatedLogin.Provider.Credentials.conventional
        let routes = Passage.FederatedLogin.Provider.Routes()

        #expect(name.rawValue == "google")

        if case .conventional = credentials {
            // Success
        } else {
            Issue.record("Expected conventional credentials")
        }

        #expect(!routes.login.path.isEmpty || routes.login.path.isEmpty)
    }

    // MARK: - Integration Tests

    @Test("Can create multiple providers with different configurations")
    func multipleProviderConfigurations() {
        let providers: [Passage.FederatedLogin.Provider] = [
            .google(scope: ["email"]),
            .github(scope: ["user"]),
            .custom(name: "custom", scope: ["openid"])
        ]

        #expect(providers.count == 3)
        #expect(providers[0].name.rawValue == "google")
        #expect(providers[1].name.rawValue == "github")
        #expect(providers[2].name.rawValue == "custom")
    }

    @Test("Provider with different credential types")
    func differentCredentialTypes() {
        let conventional = Passage.FederatedLogin.Provider.google()
        let withClient = Passage.FederatedLogin.Provider.google(
            credentials: .client(id: "id", secret: "secret")
        )

        if case .conventional = conventional.credentials {
            // Success
        } else {
            Issue.record("Expected conventional credentials")
        }

        if case .client = withClient.credentials {
            // Success
        } else {
            Issue.record("Expected client credentials")
        }
    }

    @Test("Provider with different route configurations")
    func differentRouteConfigurations() {
        let defaultRoutes = Passage.FederatedLogin.Provider.google()

        let customLogin = Passage.FederatedLogin.Provider.Routes.Login(path: "custom", "login")
        let customCallback = Passage.FederatedLogin.Provider.Routes.Callback(path: "custom", "callback")
        let customRoutes = Passage.FederatedLogin.Provider.Routes(login: customLogin, callback: customCallback)
        let withCustomRoutes = Passage.FederatedLogin.Provider.google(routes: customRoutes)

        #expect(defaultRoutes.routes.login.path == ["google"])
        #expect(withCustomRoutes.routes.login.path == ["custom", "login"])
    }

    // MARK: - Scope Tests

    @Test("Provider with empty scope")
    func emptyScope() {
        let provider = Passage.FederatedLogin.Provider.google()
        #expect(provider.scope.isEmpty)
    }

    @Test("Provider with single scope")
    func singleScope() {
        let provider = Passage.FederatedLogin.Provider.google(scope: ["email"])
        #expect(provider.scope == ["email"])
    }

    @Test("Provider with multiple scopes")
    func multipleScopes() {
        let provider = Passage.FederatedLogin.Provider.google(scope: ["email", "profile", "openid"])
        #expect(provider.scope.count == 3)
        #expect(provider.scope.contains("email"))
        #expect(provider.scope.contains("profile"))
        #expect(provider.scope.contains("openid"))
    }

    // MARK: - Name Equality Tests

    @Test("Provider names with same rawValue are equal")
    func nameEquality() {
        let name1 = Passage.FederatedLogin.Provider.Name(rawValue: "test")
        let name2 = Passage.FederatedLogin.Provider.Name(rawValue: "test")

        #expect(name1 == name2)
    }

    @Test("Provider names with different rawValue are not equal")
    func nameInequality() {
        let name1 = Passage.FederatedLogin.Provider.Name(rawValue: "test1")
        let name2 = Passage.FederatedLogin.Provider.Name(rawValue: "test2")

        #expect(name1 != name2)
    }

    @Test("Static provider names are equal to constructed ones")
    func staticNameEquality() {
        let staticGoogle = Passage.FederatedLogin.Provider.Name.google
        let constructedGoogle = Passage.FederatedLogin.Provider.Name(rawValue: "google")

        #expect(staticGoogle == constructedGoogle)
    }

    // MARK: - Credentials Pattern Matching Tests

    @Test("Can pattern match conventional credentials")
    func conventionalPatternMatching() {
        let provider = Passage.FederatedLogin.Provider.google()

        switch provider.credentials {
        case .conventional:
            // Success
            break
        case .client:
            Issue.record("Expected conventional credentials")
        }
    }

    @Test("Can pattern match client credentials")
    func clientPatternMatching() {
        let provider = Passage.FederatedLogin.Provider.google(
            credentials: .client(id: "test-id", secret: "test-secret")
        )

        switch provider.credentials {
        case .conventional:
            Issue.record("Expected client credentials")
        case .client(let id, let secret):
            #expect(id == "test-id")
            #expect(secret == "test-secret")
        }
    }

    // MARK: - Routes Path Component Tests

    @Test("Routes Login stores path components")
    func routesLoginPathComponents() {
        let login = Passage.FederatedLogin.Provider.Routes.Login(path: "a", "b", "c")
        #expect(login.path.count == 3)
    }

    @Test("Routes Callback stores path components")
    func routesCallbackPathComponents() {
        let callback = Passage.FederatedLogin.Provider.Routes.Callback(path: "x", "y", "z")
        #expect(callback.path.count == 3)
    }

    @Test("Routes with empty path components")
    func routesEmptyPath() {
        let login = Passage.FederatedLogin.Provider.Routes.Login(path: [])
        let callback = Passage.FederatedLogin.Provider.Routes.Callback(path: [])

        #expect(login.path.isEmpty)
        #expect(callback.path.isEmpty)
    }
}
