import Testing
import Vapor
@testable import Passage

@Suite("Identity Route Collection Tests")
struct IdentityRouteCollectionTests {

    // MARK: - Initialization Tests

    @Test("Passage.Identity.RouteCollection initialization with default routes")
    func routeCollectionInitialization() {
        let routes = Passage.Configuration.Routes()
        let collection = Passage.Identity.RouteCollection(routes: routes)

        #expect(collection.routes.register.path.count == 1)
        #expect(collection.routes.login.path.count == 1)
        #expect(collection.routes.logout.path.count == 1)
        #expect(collection.routes.refreshToken.path.count == 1)
        #expect(collection.routes.currentUser.path.count == 1)
    }

    @Test("Passage.Identity.RouteCollection initialization with custom routes")
    func routeCollectionWithCustomRoutes() {
        let routes = Passage.Configuration.Routes(
            register: .init(path: "signup"),
            login: .init(path: "signin"),
            logout: .init(path: "signout"),
            refreshToken: .init(path: "token", "refresh"),
            currentUser: .init(path: "user", "profile")
        )
        let collection = Passage.Identity.RouteCollection(routes: routes)

        #expect(collection.routes.register.path.count == 1)
        #expect(collection.routes.register.path[0] == PathComponent.constant("signup"))
        #expect(collection.routes.login.path[0] == PathComponent.constant("signin"))
        #expect(collection.routes.logout.path[0] == PathComponent.constant("signout"))
        #expect(collection.routes.refreshToken.path.count == 2)
        #expect(collection.routes.currentUser.path.count == 2)
    }

    @Test("Passage.Identity.RouteCollection stores routes configuration")
    func routeCollectionStoresConfiguration() {
        let routes = Passage.Configuration.Routes(
            group: "api", "v1"
        )
        let collection = Passage.Identity.RouteCollection(routes: routes)

        #expect(collection.routes.group.count == 2)
        #expect(collection.routes.group[0] == PathComponent.constant("api"))
        #expect(collection.routes.group[1] == PathComponent.constant("v1"))
    }

    // MARK: - Protocol Conformance Tests

    @Test("Passage.Identity.RouteCollection conforms to RouteCollection")
    func routeCollectionConformsToProtocol() {
        let routes = Passage.Configuration.Routes()
        let collection = Passage.Identity.RouteCollection(routes: routes)

        let _: any RouteCollection = collection
    }

    // MARK: - Route Path Configuration Tests

    @Test("Passage.Identity.RouteCollection with no group")
    func routeCollectionWithNoGroup() {
        let routes = Passage.Configuration.Routes()
        let collection = Passage.Identity.RouteCollection(routes: routes)

        #expect(collection.routes.group.count == 1)
        #expect(collection.routes.group[0] == PathComponent.constant("auth"))
    }

    @Test("Passage.Identity.RouteCollection with auth group")
    func routeCollectionWithAuthGroup() {
        let routes = Passage.Configuration.Routes(group: "auth")
        let collection = Passage.Identity.RouteCollection(routes: routes)

        #expect(collection.routes.group.count == 1)
        #expect(collection.routes.group[0] == PathComponent.constant("auth"))
    }

    @Test("Passage.Identity.RouteCollection with nested group")
    func routeCollectionWithNestedGroup() {
        let routes = Passage.Configuration.Routes(group: "api", "auth")
        let collection = Passage.Identity.RouteCollection(routes: routes)

        #expect(collection.routes.group.count == 2)
        #expect(collection.routes.group[0] == PathComponent.constant("api"))
        #expect(collection.routes.group[1] == PathComponent.constant("auth"))
    }

    @Test("Passage.Identity.RouteCollection with versioned group")
    func routeCollectionWithVersionedGroup() {
        let routes = Passage.Configuration.Routes(group: "v1", "identity")
        let collection = Passage.Identity.RouteCollection(routes: routes)

        #expect(collection.routes.group.count == 2)
        #expect(collection.routes.group[0] == PathComponent.constant("v1"))
        #expect(collection.routes.group[1] == PathComponent.constant("identity"))
    }

    @Test("Passage.Identity.RouteCollection default route paths")
    func routeCollectionDefaultPaths() {
        let routes = Passage.Configuration.Routes()
        let collection = Passage.Identity.RouteCollection(routes: routes)

        // Verify default paths match configuration defaults
        #expect(collection.routes.register.path == [PathComponent.constant("register")])
        #expect(collection.routes.login.path == [PathComponent.constant("login")])
        #expect(collection.routes.logout.path == [PathComponent.constant("logout")])
        #expect(collection.routes.refreshToken.path == [PathComponent.constant("refresh-token")])
        #expect(collection.routes.currentUser.path == [PathComponent.constant("me")])
    }

    @Test("Passage.Identity.RouteCollection with custom path components")
    func routeCollectionWithCustomPaths() {
        let routes = Passage.Configuration.Routes(
            register: .init(path: "users", "create"),
            login: .init(path: "auth", "login"),
            logout: .init(path: "auth", "logout"),
            refreshToken: .init(path: "auth", "refresh"),
            currentUser: .init(path: "users", "me")
        )
        let collection = Passage.Identity.RouteCollection(routes: routes)

        #expect(collection.routes.register.path.count == 2)
        #expect(collection.routes.login.path.count == 2)
        #expect(collection.routes.logout.path.count == 2)
        #expect(collection.routes.refreshToken.path.count == 2)
        #expect(collection.routes.currentUser.path.count == 2)
    }

    @Test("Passage.Identity.RouteCollection preserves route configuration")
    func routeCollectionPreservesConfiguration() {
        let customRegister = Passage.Configuration.Routes.Register(path: "custom", "register")
        let customLogin = Passage.Configuration.Routes.Login(path: "custom", "login")

        let routes = Passage.Configuration.Routes(
            register: customRegister,
            login: customLogin
        )
        let collection = Passage.Identity.RouteCollection(routes: routes)

        // Verify the collection preserves the exact route configuration
        #expect(collection.routes.register.path == customRegister.path)
        #expect(collection.routes.login.path == customLogin.path)
    }

    // MARK: - Multiple Instance Tests

    @Test("Passage.Identity.RouteCollection can be instantiated multiple times")
    func multipleRouteCollectionInstances() {
        let routes1 = Passage.Configuration.Routes(group: "api")
        let routes2 = Passage.Configuration.Routes(group: "admin")

        let collection1 = Passage.Identity.RouteCollection(routes: routes1)
        let collection2 = Passage.Identity.RouteCollection(routes: routes2)

        #expect(collection1.routes.group[0] == PathComponent.constant("api"))
        #expect(collection2.routes.group[0] == PathComponent.constant("admin"))
    }

    @Test("Passage.Identity.RouteCollection instances are independent")
    func routeCollectionIndependence() {
        let routes1 = Passage.Configuration.Routes(
            register: .init(path: "register1")
        )
        let routes2 = Passage.Configuration.Routes(
            register: .init(path: "register2")
        )

        let collection1 = Passage.Identity.RouteCollection(routes: routes1)
        let collection2 = Passage.Identity.RouteCollection(routes: routes2)

        #expect(collection1.routes.register.path[0] == PathComponent.constant("register1"))
        #expect(collection2.routes.register.path[0] == PathComponent.constant("register2"))
    }
}
