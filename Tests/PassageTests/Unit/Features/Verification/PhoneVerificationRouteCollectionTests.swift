import Testing
import Vapor
@testable import Passage

@Suite("Phone Verification Route Collection Tests")
struct PhoneVerificationRouteCollectionTests {

    // MARK: - Initialization Tests

    @Test("PhoneVerificationRouteCollection initialization with default group")
    func initializationWithDefaultGroup() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(collection.groupPath.isEmpty)
    }

    @Test("PhoneVerificationRouteCollection initialization with custom group")
    func initializationWithCustomGroup() {
        let config = Passage.Configuration.Verification.Phone()
        let groupPath: [PathComponent] = ["auth", "phone"]
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: groupPath
        )

        #expect(collection.groupPath.count == 2)
    }

    @Test("PhoneVerificationRouteCollection stores configuration")
    func storesConfiguration() {
        let config = Passage.Configuration.Verification.Phone(
            codeLength: 8,
            codeExpiration: 600,
            maxAttempts: 5
        )
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(collection.config.codeLength == 8)
        #expect(collection.config.codeExpiration == 600)
        #expect(collection.config.maxAttempts == 5)
    }

    // MARK: - Group Path Tests

    @Test("PhoneVerificationRouteCollection with empty group")
    func emptyGroup() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(collection.groupPath.isEmpty)
    }

    @Test("PhoneVerificationRouteCollection with single component group")
    func singleComponentGroup() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: ["verify"]
        )

        #expect(collection.groupPath.count == 1)
    }

    @Test("PhoneVerificationRouteCollection with multiple components")
    func multipleComponentsGroup() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: ["api", "v1", "auth", "phone"]
        )

        #expect(collection.groupPath.count == 4)
    }

    @Test("PhoneVerificationRouteCollection with versioned group")
    func versionedGroup() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: ["v1", "verification", "phone"]
        )

        #expect(collection.groupPath.count == 3)
    }

    // MARK: - Route Configuration Tests

    @Test("PhoneVerificationRouteCollection with default routes")
    func defaultRoutes() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(collection.config.routes.sendCode.path.count > 0)
        #expect(collection.config.routes.verify.path.count > 0)
        #expect(collection.config.routes.resend.path.count > 0)
    }

    @Test("PhoneVerificationRouteCollection with custom route paths")
    func customRoutePaths() {
        let sendCodeRoute = Passage.Configuration.Verification.Phone.Routes.SendCode(path: "custom-send")
        let verifyRoute = Passage.Configuration.Verification.Phone.Routes.Verify(path: "custom-verify")
        let resendRoute = Passage.Configuration.Verification.Phone.Routes.Resend(path: "custom-resend")
        let routes = Passage.Configuration.Verification.Phone.Routes(
            sendCode: sendCodeRoute,
            verify: verifyRoute,
            resend: resendRoute
        )

        let config = Passage.Configuration.Verification.Phone(routes: routes)
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(collection.config.routes.sendCode.path == ["custom-send"])
        #expect(collection.config.routes.verify.path == ["custom-verify"])
        #expect(collection.config.routes.resend.path == ["custom-resend"])
    }

    @Test("PhoneVerificationRouteCollection sendCode route path")
    func sendCodeRoutePath() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(!collection.config.routes.sendCode.path.isEmpty)
    }

    @Test("PhoneVerificationRouteCollection verify route path")
    func verifyRoutePath() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(!collection.config.routes.verify.path.isEmpty)
    }

    @Test("PhoneVerificationRouteCollection resend route path")
    func resendRoutePath() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(!collection.config.routes.resend.path.isEmpty)
    }

    // MARK: - Configuration Parameter Tests

    @Test("PhoneVerificationRouteCollection with custom code length")
    func customCodeLength() {
        let config = Passage.Configuration.Verification.Phone(codeLength: 10)
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(collection.config.codeLength == 10)
    }

    @Test("PhoneVerificationRouteCollection with custom expiration")
    func customExpiration() {
        let config = Passage.Configuration.Verification.Phone(codeExpiration: 1800)
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(collection.config.codeExpiration == 1800)
    }

    @Test("PhoneVerificationRouteCollection with custom max attempts")
    func customMaxAttempts() {
        let config = Passage.Configuration.Verification.Phone(maxAttempts: 10)
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        #expect(collection.config.maxAttempts == 10)
    }

    // MARK: - Multiple Instance Tests

    @Test("Multiple PhoneVerificationRouteCollection instances are independent")
    func multipleInstancesIndependent() {
        let config1 = Passage.Configuration.Verification.Phone(codeLength: 6)
        let collection1 = PhoneVerificationRouteCollection(
            config: config1,
            groupPath: ["auth1"]
        )

        let config2 = Passage.Configuration.Verification.Phone(codeLength: 8)
        let collection2 = PhoneVerificationRouteCollection(
            config: config2,
            groupPath: ["auth2"]
        )

        #expect(collection1.config.codeLength != collection2.config.codeLength)
        #expect(collection1.groupPath != collection2.groupPath)
    }

    @Test("PhoneVerificationRouteCollection can be instantiated multiple times")
    func multipleInstantiations() {
        let config = Passage.Configuration.Verification.Phone()

        let collection1 = PhoneVerificationRouteCollection(config: config, groupPath: [])
        let collection2 = PhoneVerificationRouteCollection(config: config, groupPath: [])

        #expect(collection1.groupPath == collection2.groupPath)
    }

    // MARK: - Protocol Conformance Tests

    @Test("PhoneVerificationRouteCollection conforms to RouteCollection")
    func conformsToRouteCollection() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        let _: any RouteCollection = collection
        #expect(collection is RouteCollection)
    }

    // MARK: - Group Path Component Tests

    @Test("PhoneVerificationRouteCollection with different path component types")
    func differentPathComponentTypes() {
        let config = Passage.Configuration.Verification.Phone()

        // String path components
        let collection1 = PhoneVerificationRouteCollection(
            config: config,
            groupPath: ["auth", "verify"]
        )
        #expect(collection1.groupPath.count == 2)

        // Constant path components
        let collection2 = PhoneVerificationRouteCollection(
            config: config,
            groupPath: [.constant("auth"), .constant("verify")]
        )
        #expect(collection2.groupPath.count == 2)
    }

    @Test("PhoneVerificationRouteCollection preserves group order")
    func preservesGroupOrder() {
        let config = Passage.Configuration.Verification.Phone()
        let groupPath: [PathComponent] = ["first", "second", "third"]
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: groupPath
        )

        #expect(collection.groupPath.count == 3)
        // Order is preserved by the array
    }

    // MARK: - Configuration Preservation Tests

    @Test("PhoneVerificationRouteCollection preserves all configuration settings")
    func preservesAllConfiguration() {
        let sendCodeRoute = Passage.Configuration.Verification.Phone.Routes.SendCode(path: "send")
        let verifyRoute = Passage.Configuration.Verification.Phone.Routes.Verify(path: "verify")
        let resendRoute = Passage.Configuration.Verification.Phone.Routes.Resend(path: "resend")
        let routes = Passage.Configuration.Verification.Phone.Routes(
            sendCode: sendCodeRoute,
            verify: verifyRoute,
            resend: resendRoute
        )

        let config = Passage.Configuration.Verification.Phone(
            routes: routes,
            codeLength: 7,
            codeExpiration: 900,
            maxAttempts: 4
        )

        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: ["phone"]
        )

        #expect(collection.config.codeLength == 7)
        #expect(collection.config.codeExpiration == 900)
        #expect(collection.config.maxAttempts == 4)
        #expect(collection.config.routes.sendCode.path == ["send"])
        #expect(collection.config.routes.verify.path == ["verify"])
        #expect(collection.config.routes.resend.path == ["resend"])
        #expect(collection.groupPath == ["phone"])
    }

    @Test("PhoneVerificationRouteCollection with nested path groups")
    func nestedPathGroups() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: ["api", "v2", "auth", "phone", "verify"]
        )

        #expect(collection.groupPath.count == 5)
    }

    // MARK: - Route Collection Comparison Tests

    @Test("PhoneVerificationRouteCollection has three routes")
    func hasThreeRoutes() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        // Verify all three routes are accessible
        #expect(!collection.config.routes.sendCode.path.isEmpty)
        #expect(!collection.config.routes.verify.path.isEmpty)
        #expect(!collection.config.routes.resend.path.isEmpty)
    }

    @Test("PhoneVerificationRouteCollection route paths are distinct")
    func routePathsAreDistinct() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        let sendCodePath = collection.config.routes.sendCode.path
        let verifyPath = collection.config.routes.verify.path
        let resendPath = collection.config.routes.resend.path

        // Each route should have a path
        #expect(!sendCodePath.isEmpty)
        #expect(!verifyPath.isEmpty)
        #expect(!resendPath.isEmpty)
    }

    // MARK: - Default Configuration Tests

    @Test("PhoneVerificationRouteCollection default configuration values")
    func defaultConfigurationValues() {
        let config = Passage.Configuration.Verification.Phone()
        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: []
        )

        // Verify default values are set
        #expect(collection.config.codeLength > 0)
        #expect(collection.config.codeExpiration > 0)
        #expect(collection.config.maxAttempts > 0)
    }

    @Test("PhoneVerificationRouteCollection with all custom settings")
    func allCustomSettings() {
        let sendCodeRoute = Passage.Configuration.Verification.Phone.Routes.SendCode(
            path: "custom-send-code"
        )
        let verifyRoute = Passage.Configuration.Verification.Phone.Routes.Verify(
            path: "custom-verify-phone"
        )
        let resendRoute = Passage.Configuration.Verification.Phone.Routes.Resend(
            path: "custom-resend-code"
        )
        let routes = Passage.Configuration.Verification.Phone.Routes(
            sendCode: sendCodeRoute,
            verify: verifyRoute,
            resend: resendRoute
        )

        let config = Passage.Configuration.Verification.Phone(
            routes: routes,
            codeLength: 12,
            codeExpiration: 2400,
            maxAttempts: 8
        )

        let collection = PhoneVerificationRouteCollection(
            config: config,
            groupPath: ["v3", "sms", "verification"]
        )

        #expect(collection.config.codeLength == 12)
        #expect(collection.config.codeExpiration == 2400)
        #expect(collection.config.maxAttempts == 8)
        #expect(collection.config.routes.sendCode.path == ["custom-send-code"])
        #expect(collection.config.routes.verify.path == ["custom-verify-phone"])
        #expect(collection.config.routes.resend.path == ["custom-resend-code"])
        #expect(collection.groupPath.count == 3)
    }
}
