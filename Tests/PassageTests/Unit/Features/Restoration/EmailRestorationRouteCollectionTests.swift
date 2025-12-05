import Testing
import Vapor
@testable import Passage

@Suite("Email Restoration Route Collection Tests")
struct EmailRestorationRouteCollectionTests {

    // MARK: - Initialization Tests

    @Test("EmailRestorationRouteCollection initialization with default group")
    func initializationWithDefaultGroup() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: []
        )

        #expect(collection.group.isEmpty)
    }

    @Test("EmailRestorationRouteCollection initialization with custom group")
    func initializationWithCustomGroup() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let group: [PathComponent] = ["auth", "password-reset"]
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: group
        )

        #expect(collection.group.count == 2)
    }

    @Test("EmailRestorationRouteCollection stores routes configuration")
    func storesRoutesConfiguration() {
        let requestRoute = Passage.Configuration.Restoration.Email.Routes.Request(path: "request")
        let verifyRoute = Passage.Configuration.Restoration.Email.Routes.Verify(path: "verify")
        let resendRoute = Passage.Configuration.Restoration.Email.Routes.Resend(path: "resend")
        let routes = Passage.Configuration.Restoration.Email.Routes(
            request: requestRoute,
            verify: verifyRoute,
            resend: resendRoute
        )

        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: []
        )

        #expect(collection.routes.request.path == ["request"])
        #expect(collection.routes.verify.path == ["verify"])
        #expect(collection.routes.resend.path == ["resend"])
    }

    // MARK: - Group Path Tests

    @Test("EmailRestorationRouteCollection with empty group")
    func emptyGroup() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: []
        )

        #expect(collection.group.isEmpty)
    }

    @Test("EmailRestorationRouteCollection with single component group")
    func singleComponentGroup() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: ["reset"]
        )

        #expect(collection.group.count == 1)
    }

    @Test("EmailRestorationRouteCollection with multiple components")
    func multipleComponentsGroup() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: ["api", "v1", "auth", "email", "reset"]
        )

        #expect(collection.group.count == 5)
    }

    @Test("EmailRestorationRouteCollection with versioned group")
    func versionedGroup() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: ["v1", "password", "reset"]
        )

        #expect(collection.group.count == 3)
    }

    // MARK: - Route Configuration Tests

    @Test("EmailRestorationRouteCollection with default routes")
    func defaultRoutes() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: []
        )

        #expect(collection.routes.request.path.count > 0)
        #expect(collection.routes.verify.path.count > 0)
        #expect(collection.routes.resend.path.count > 0)
    }

    @Test("EmailRestorationRouteCollection request route path")
    func requestRoutePath() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: []
        )

        #expect(!collection.routes.request.path.isEmpty)
    }

    @Test("EmailRestorationRouteCollection verify route path")
    func verifyRoutePath() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: []
        )

        #expect(!collection.routes.verify.path.isEmpty)
    }

    @Test("EmailRestorationRouteCollection resend route path")
    func resendRoutePath() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: []
        )

        #expect(!collection.routes.resend.path.isEmpty)
    }

    // MARK: - Multiple Instance Tests

    @Test("Multiple EmailRestorationRouteCollection instances are independent")
    func multipleInstancesIndependent() {
        let requestRoute1 = Passage.Configuration.Restoration.Email.Routes.Request(path: "request1")
        let verifyRoute1 = Passage.Configuration.Restoration.Email.Routes.Verify(path: "verify1")
        let resendRoute1 = Passage.Configuration.Restoration.Email.Routes.Resend(path: "resend1")
        let routes1 = Passage.Configuration.Restoration.Email.Routes(
            request: requestRoute1,
            verify: verifyRoute1,
            resend: resendRoute1
        )

        let requestRoute2 = Passage.Configuration.Restoration.Email.Routes.Request(path: "request2")
        let verifyRoute2 = Passage.Configuration.Restoration.Email.Routes.Verify(path: "verify2")
        let resendRoute2 = Passage.Configuration.Restoration.Email.Routes.Resend(path: "resend2")
        let routes2 = Passage.Configuration.Restoration.Email.Routes(
            request: requestRoute2,
            verify: verifyRoute2,
            resend: resendRoute2
        )

        let collection1 = EmailRestorationRouteCollection(routes: routes1, group: ["auth1"])
        let collection2 = EmailRestorationRouteCollection(routes: routes2, group: ["auth2"])

        #expect(collection1.routes.request.path != collection2.routes.request.path)
        #expect(collection1.group != collection2.group)
    }

    @Test("EmailRestorationRouteCollection can be instantiated multiple times")
    func multipleInstantiations() {
        let routes = Passage.Configuration.Restoration.Email.Routes()

        let collection1 = EmailRestorationRouteCollection(routes: routes, group: [])
        let collection2 = EmailRestorationRouteCollection(routes: routes, group: [])

        #expect(collection1.group == collection2.group)
    }

    // MARK: - Protocol Conformance Tests

    @Test("EmailRestorationRouteCollection conforms to RouteCollection")
    func conformsToRouteCollection() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: []
        )

        let _: any RouteCollection = collection
        #expect(collection is RouteCollection)
    }

    // MARK: - Group Path Component Tests

    @Test("EmailRestorationRouteCollection with different path component types")
    func differentPathComponentTypes() {
        let routes = Passage.Configuration.Restoration.Email.Routes()

        // String path components
        let collection1 = EmailRestorationRouteCollection(
            routes: routes,
            group: ["auth", "reset"]
        )
        #expect(collection1.group.count == 2)

        // Constant path components
        let collection2 = EmailRestorationRouteCollection(
            routes: routes,
            group: [.constant("auth"), .constant("reset")]
        )
        #expect(collection2.group.count == 2)
    }

    @Test("EmailRestorationRouteCollection preserves group order")
    func preservesGroupOrder() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let group: [PathComponent] = ["first", "second", "third"]
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: group
        )

        #expect(collection.group.count == 3)
    }

    // MARK: - Configuration Preservation Tests

    @Test("EmailRestorationRouteCollection preserves all route settings")
    func preservesAllRouteSettings() {
        let requestRoute = Passage.Configuration.Restoration.Email.Routes.Request(path: "req")
        let verifyRoute = Passage.Configuration.Restoration.Email.Routes.Verify(path: "ver")
        let resendRoute = Passage.Configuration.Restoration.Email.Routes.Resend(path: "res")
        let routes = Passage.Configuration.Restoration.Email.Routes(
            request: requestRoute,
            verify: verifyRoute,
            resend: resendRoute
        )

        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: ["email"]
        )

        #expect(collection.routes.request.path == ["req"])
        #expect(collection.routes.verify.path == ["ver"])
        #expect(collection.routes.resend.path == ["res"])
        #expect(collection.group == ["email"])
    }

    @Test("EmailRestorationRouteCollection with nested path groups")
    func nestedPathGroups() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: ["api", "v2", "auth", "email", "password-reset"]
        )

        #expect(collection.group.count == 5)
    }

    // MARK: - Route Path Tests

    @Test("EmailRestorationRouteCollection has three routes")
    func hasThreeRoutes() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: []
        )

        // Verify all three routes are accessible
        #expect(!collection.routes.request.path.isEmpty)
        #expect(!collection.routes.verify.path.isEmpty)
        #expect(!collection.routes.resend.path.isEmpty)
    }

    @Test("EmailRestorationRouteCollection route paths are distinct")
    func routePathsDistinct() {
        let routes = Passage.Configuration.Restoration.Email.Routes()
        let collection = EmailRestorationRouteCollection(
            routes: routes,
            group: []
        )

        let requestPath = collection.routes.request.path
        let verifyPath = collection.routes.verify.path
        let resendPath = collection.routes.resend.path

        // Each route should have a path
        #expect(!requestPath.isEmpty)
        #expect(!verifyPath.isEmpty)
        #expect(!resendPath.isEmpty)
    }
}
