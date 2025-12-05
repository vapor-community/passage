import Testing
import Foundation
import Vapor
@testable import Passage

@Suite("Federated Login Configuration Tests")
struct FederatedLoginConfigurationTests {

    // MARK: - FederatedLogin Routes Tests

    @Test("FederatedLogin routes default group")
    func routesDefaultGroup() {
        let routes = Passage.Configuration.FederatedLogin.Routes()

        #expect(routes.group.count == 1)
        #expect(routes.group[0].description == "oauth")
    }

    @Test("FederatedLogin routes custom group")
    func routesCustomGroup() {
        let routes = Passage.Configuration.FederatedLogin.Routes(group: "api", "auth", "social")

        #expect(routes.group.count == 3)
        #expect(routes.group[0].description == "api")
        #expect(routes.group[1].description == "auth")
        #expect(routes.group[2].description == "social")
    }

    // MARK: - FederatedLogin Configuration Tests

    @Test("FederatedLogin default configuration")
    func federatedLoginDefault() {
        let oauth = Passage.Configuration.FederatedLogin(routes: .init(), providers: [])

        #expect(oauth.routes.group[0].description == "oauth")
        #expect(oauth.providers.isEmpty)
        #expect(oauth.redirectLocation == "/")
    }

    @Test("FederatedLogin with custom redirect")
    func federatedLoginCustomRedirect() {
        let oauth = Passage.Configuration.FederatedLogin(
            routes: .init(),
            providers: [],
            redirectLocation: "/dashboard"
        )

        #expect(oauth.redirectLocation == "/dashboard")
    }

    @Test("FederatedLogin with providers")
    func federatedLoginWithProviders() {
        let providers: [Passage.FederatedLogin.Provider] = [
            .google(),
            .github()
        ]

        let oauth = Passage.Configuration.FederatedLogin(
            routes: .init(),
            providers: providers
        )

        #expect(oauth.providers.count == 2)
        #expect(oauth.providers[0].name == .google)
        #expect(oauth.providers[1].name == .github)
    }

    // MARK: - Path Helper Tests

    @Test("Login path for provider")
    func loginPathForProvider() {
        let provider = Passage.FederatedLogin.Provider.google()
        let config = Passage.Configuration.FederatedLogin(
            routes: .init(group: "api", "oauth"),
            providers: [provider]
        )

        let path = config.loginPath(for: provider)

        #expect(path.count == 3)
        #expect(path[0].description == "api")
        #expect(path[1].description == "oauth")
        #expect(path[2].description == "google")
    }

    @Test("Callback path for provider")
    func callbackPathForProvider() {
        let provider = Passage.FederatedLogin.Provider.github()
        let config = Passage.Configuration.FederatedLogin(
            routes: .init(group: "auth"),
            providers: [provider]
        )

        let path = config.callbackPath(for: provider)

        #expect(path.count == 3)
        #expect(path[0].description == "auth")
        #expect(path[1].description == "github")
        #expect(path[2].description == "callback")
    }

    @Test("Custom provider paths")
    func customProviderPaths() {
        let customRoutes = Passage.FederatedLogin.Provider.Routes(
            login: .init(path: "custom", "login"),
            callback: .init(path: "custom", "cb")
        )

        let provider = Passage.FederatedLogin.Provider(
            name: .init(rawValue: "custom"),
            routes: customRoutes
        )

        let config = Passage.Configuration.FederatedLogin(
            routes: .init(),
            providers: [provider]
        )

        let loginPath = config.loginPath(for: provider)
        let callbackPath = config.callbackPath(for: provider)

        #expect(loginPath[1].description == "custom")
        #expect(loginPath[2].description == "login")
        #expect(callbackPath[1].description == "custom")
        #expect(callbackPath[2].description == "cb")
    }

    @Test("FederatedLogin Sendable conformance")
    func federatedLoginSendableConformance() {
        let oauth: Passage.Configuration.FederatedLogin = .init(
            routes: .init(),
            providers: []
        )

        let _: any Sendable = oauth
        let _: any Sendable = oauth.routes
    }
}
