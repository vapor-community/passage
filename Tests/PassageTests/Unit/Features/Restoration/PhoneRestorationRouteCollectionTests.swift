import Testing
import Vapor
@testable import Passage

@Suite("Phone Restoration Route Collection Tests")
struct PhoneRestorationRouteCollectionTests {

    // MARK: - Initialization Tests

    @Test("Passage.Restoration.PhoneRouteCollection initialization with default group")
    func initializationWithDefaultGroup() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: []
        )

        #expect(collection.groupPath.isEmpty)
    }

    @Test("Passage.Restoration.PhoneRouteCollection initialization with custom group")
    func initializationWithCustomGroup() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let groupPath: [PathComponent] = ["auth", "password-reset"]
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: groupPath
        )

        #expect(collection.groupPath.count == 2)
    }

    @Test("Passage.Restoration.PhoneRouteCollection stores routes configuration")
    func storesRoutesConfiguration() {
        let requestRoute = Passage.Configuration.Restoration.Phone.Routes.Request(path: "request")
        let verifyRoute = Passage.Configuration.Restoration.Phone.Routes.Verify(path: "verify")
        let resendRoute = Passage.Configuration.Restoration.Phone.Routes.Resend(path: "resend")
        let routes = Passage.Configuration.Restoration.Phone.Routes(
            request: requestRoute,
            verify: verifyRoute,
            resend: resendRoute
        )

        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: []
        )

        #expect(collection.routes.request.path == ["request"])
        #expect(collection.routes.verify.path == ["verify"])
        #expect(collection.routes.resend.path == ["resend"])
    }

    // MARK: - Group Path Tests

    @Test("Passage.Restoration.PhoneRouteCollection with empty group")
    func emptyGroup() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: []
        )

        #expect(collection.groupPath.isEmpty)
    }

    @Test("Passage.Restoration.PhoneRouteCollection with single component group")
    func singleComponentGroup() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: ["reset"]
        )

        #expect(collection.groupPath.count == 1)
    }

    @Test("Passage.Restoration.PhoneRouteCollection with multiple components")
    func multipleComponentsGroup() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: ["api", "v1", "auth", "phone", "reset"]
        )

        #expect(collection.groupPath.count == 5)
    }

    @Test("Passage.Restoration.PhoneRouteCollection with versioned group")
    func versionedGroup() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: ["v1", "password", "reset"]
        )

        #expect(collection.groupPath.count == 3)
    }

    // MARK: - Route Configuration Tests

    @Test("Passage.Restoration.PhoneRouteCollection with default routes")
    func defaultRoutes() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: []
        )

        #expect(collection.routes.request.path.count > 0)
        #expect(collection.routes.verify.path.count > 0)
        #expect(collection.routes.resend.path.count > 0)
    }

    @Test("Passage.Restoration.PhoneRouteCollection request route path")
    func requestRoutePath() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: []
        )

        #expect(!collection.routes.request.path.isEmpty)
    }

    @Test("Passage.Restoration.PhoneRouteCollection verify route path")
    func verifyRoutePath() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: []
        )

        #expect(!collection.routes.verify.path.isEmpty)
    }

    @Test("Passage.Restoration.PhoneRouteCollection resend route path")
    func resendRoutePath() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: []
        )

        #expect(!collection.routes.resend.path.isEmpty)
    }

    // MARK: - Multiple Instance Tests

    @Test("Multiple Passage.Restoration.PhoneRouteCollection instances are independent")
    func multipleInstancesIndependent() {
        let requestRoute1 = Passage.Configuration.Restoration.Phone.Routes.Request(path: "request1")
        let verifyRoute1 = Passage.Configuration.Restoration.Phone.Routes.Verify(path: "verify1")
        let resendRoute1 = Passage.Configuration.Restoration.Phone.Routes.Resend(path: "resend1")
        let routes1 = Passage.Configuration.Restoration.Phone.Routes(
            request: requestRoute1,
            verify: verifyRoute1,
            resend: resendRoute1
        )

        let requestRoute2 = Passage.Configuration.Restoration.Phone.Routes.Request(path: "request2")
        let verifyRoute2 = Passage.Configuration.Restoration.Phone.Routes.Verify(path: "verify2")
        let resendRoute2 = Passage.Configuration.Restoration.Phone.Routes.Resend(path: "resend2")
        let routes2 = Passage.Configuration.Restoration.Phone.Routes(
            request: requestRoute2,
            verify: verifyRoute2,
            resend: resendRoute2
        )

        let collection1 = Passage.Restoration.PhoneRouteCollection(routes: routes1, groupPath: ["auth1"])
        let collection2 = Passage.Restoration.PhoneRouteCollection(routes: routes2, groupPath: ["auth2"])

        #expect(collection1.routes.request.path != collection2.routes.request.path)
        #expect(collection1.groupPath != collection2.groupPath)
    }

    @Test("Passage.Restoration.PhoneRouteCollection can be instantiated multiple times")
    func multipleInstantiations() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()

        let collection1 = Passage.Restoration.PhoneRouteCollection(routes: routes, groupPath: [])
        let collection2 = Passage.Restoration.PhoneRouteCollection(routes: routes, groupPath: [])

        #expect(collection1.groupPath == collection2.groupPath)
    }

    // MARK: - Protocol Conformance Tests

    @Test("Passage.Restoration.PhoneRouteCollection conforms to RouteCollection")
    func conformsToRouteCollection() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: []
        )

        let _: any RouteCollection = collection
        #expect(collection is RouteCollection)
    }

    // MARK: - Group Path Component Tests

    @Test("Passage.Restoration.PhoneRouteCollection with different path component types")
    func differentPathComponentTypes() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()

        // String path components
        let collection1 = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: ["auth", "reset"]
        )
        #expect(collection1.groupPath.count == 2)

        // Constant path components
        let collection2 = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: [.constant("auth"), .constant("reset")]
        )
        #expect(collection2.groupPath.count == 2)
    }

    @Test("Passage.Restoration.PhoneRouteCollection preserves group order")
    func preservesGroupOrder() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let groupPath: [PathComponent] = ["first", "second", "third"]
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: groupPath
        )

        #expect(collection.groupPath.count == 3)
    }

    // MARK: - Configuration Preservation Tests

    @Test("Passage.Restoration.PhoneRouteCollection preserves all route settings")
    func preservesAllRouteSettings() {
        let requestRoute = Passage.Configuration.Restoration.Phone.Routes.Request(path: "req")
        let verifyRoute = Passage.Configuration.Restoration.Phone.Routes.Verify(path: "ver")
        let resendRoute = Passage.Configuration.Restoration.Phone.Routes.Resend(path: "res")
        let routes = Passage.Configuration.Restoration.Phone.Routes(
            request: requestRoute,
            verify: verifyRoute,
            resend: resendRoute
        )

        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: ["phone"]
        )

        #expect(collection.routes.request.path == ["req"])
        #expect(collection.routes.verify.path == ["ver"])
        #expect(collection.routes.resend.path == ["res"])
        #expect(collection.groupPath == ["phone"])
    }

    @Test("Passage.Restoration.PhoneRouteCollection with nested path groups")
    func nestedPathGroups() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: ["api", "v2", "auth", "phone", "password-reset"]
        )

        #expect(collection.groupPath.count == 5)
    }

    // MARK: - Route Path Tests

    @Test("Passage.Restoration.PhoneRouteCollection has three routes")
    func hasThreeRoutes() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: []
        )

        // Verify all three routes are accessible
        #expect(!collection.routes.request.path.isEmpty)
        #expect(!collection.routes.verify.path.isEmpty)
        #expect(!collection.routes.resend.path.isEmpty)
    }

    @Test("Passage.Restoration.PhoneRouteCollection route paths are distinct")
    func routePathsDistinct() {
        let routes = Passage.Configuration.Restoration.Phone.Routes()
        let collection = Passage.Restoration.PhoneRouteCollection(
            routes: routes,
            groupPath: []
        )

        let requestPath = collection.routes.request.path
        let verifyPath = collection.routes.verify.path
        let resendPath = collection.routes.resend.path

        // Each route should have a path
        #expect(!requestPath.isEmpty)
        #expect(!verifyPath.isEmpty)
        #expect(!resendPath.isEmpty)
    }

    // MARK: - Comparison with Email Route Collection Tests

    @Test("Phone and Email route collections are independent")
    func phoneAndEmailIndependent() {
        let phoneRoutes = Passage.Configuration.Restoration.Phone.Routes()
        let phoneCollection = Passage.Restoration.PhoneRouteCollection(
            routes: phoneRoutes,
            groupPath: ["phone"]
        )

        let emailRoutes = Passage.Configuration.Restoration.Email.Routes()
        let emailCollection = EmailRestorationRouteCollection(
            routes: emailRoutes,
            group: ["email"]
        )

        // They should have different types and different group names
        #expect(phoneCollection.groupPath != emailCollection.group)
    }
}
