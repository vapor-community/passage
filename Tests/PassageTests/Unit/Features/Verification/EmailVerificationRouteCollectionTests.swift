import Testing
import Vapor
@testable import Passage

@Suite("Email Verification Route Collection Tests")
struct EmailVerificationRouteCollectionTests {

    // MARK: - Initialization Tests

    @Test("EmailVerificationRouteCollection initialization with default group")
    func initializationWithDefaultGroup() {
        let config = Passage.Configuration.Verification.Email()
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        #expect(collection.group.isEmpty)
    }

    @Test("EmailVerificationRouteCollection initialization with custom group")
    func initializationWithCustomGroup() {
        let config = Passage.Configuration.Verification.Email()
        let group: [PathComponent] = ["auth", "email"]
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: group
        )

        #expect(collection.group.count == 2)
    }

    @Test("EmailVerificationRouteCollection stores configuration")
    func storesConfiguration() {
        let config = Passage.Configuration.Verification.Email(
            codeLength: 8,
            codeExpiration: 600,
            maxAttempts: 5
        )
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        #expect(collection.config.codeLength == 8)
        #expect(collection.config.codeExpiration == 600)
        #expect(collection.config.maxAttempts == 5)
    }

    // MARK: - Group Path Tests

    @Test("EmailVerificationRouteCollection with empty group")
    func emptyGroup() {
        let config = Passage.Configuration.Verification.Email()
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        #expect(collection.group.isEmpty)
    }

    @Test("EmailVerificationRouteCollection with single component group")
    func singleComponentGroup() {
        let config = Passage.Configuration.Verification.Email()
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: ["verify"]
        )

        #expect(collection.group.count == 1)
    }

    @Test("EmailVerificationRouteCollection with multiple components")
    func multipleComponentsGroup() {
        let config = Passage.Configuration.Verification.Email()
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: ["api", "v1", "auth", "email"]
        )

        #expect(collection.group.count == 4)
    }

    @Test("EmailVerificationRouteCollection with versioned group")
    func versionedGroup() {
        let config = Passage.Configuration.Verification.Email()
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: ["v1", "verification", "email"]
        )

        #expect(collection.group.count == 3)
    }

    // MARK: - Route Configuration Tests

    @Test("EmailVerificationRouteCollection with default routes")
    func defaultRoutes() {
        let config = Passage.Configuration.Verification.Email()
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        #expect(collection.config.routes.verify.path.count > 0)
        #expect(collection.config.routes.resend.path.count > 0)
    }

    @Test("EmailVerificationRouteCollection with custom route paths")
    func customRoutePaths() {
        let verifyRoute = Passage.Configuration.Verification.Email.Routes.Verify(path: "custom-verify")
        let resendRoute = Passage.Configuration.Verification.Email.Routes.Resend(path: "custom-resend")
        let routes = Passage.Configuration.Verification.Email.Routes(
            verify: verifyRoute,
            resend: resendRoute
        )

        let config = Passage.Configuration.Verification.Email(routes: routes)
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        #expect(collection.config.routes.verify.path == ["custom-verify"])
        #expect(collection.config.routes.resend.path == ["custom-resend"])
    }

    @Test("EmailVerificationRouteCollection verify route path")
    func verifyRoutePath() {
        let config = Passage.Configuration.Verification.Email()
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        #expect(!collection.config.routes.verify.path.isEmpty)
    }

    @Test("EmailVerificationRouteCollection resend route path")
    func resendRoutePath() {
        let config = Passage.Configuration.Verification.Email()
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        #expect(!collection.config.routes.resend.path.isEmpty)
    }

    // MARK: - Configuration Parameter Tests

    @Test("EmailVerificationRouteCollection with custom code length")
    func customCodeLength() {
        let config = Passage.Configuration.Verification.Email(codeLength: 10)
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        #expect(collection.config.codeLength == 10)
    }

    @Test("EmailVerificationRouteCollection with custom expiration")
    func customExpiration() {
        let config = Passage.Configuration.Verification.Email(codeExpiration: 1800)
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        #expect(collection.config.codeExpiration == 1800)
    }

    @Test("EmailVerificationRouteCollection with custom max attempts")
    func customMaxAttempts() {
        let config = Passage.Configuration.Verification.Email(maxAttempts: 10)
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        #expect(collection.config.maxAttempts == 10)
    }

    // MARK: - Multiple Instance Tests

    @Test("Multiple EmailVerificationRouteCollection instances are independent")
    func multipleInstancesIndependent() {
        let config1 = Passage.Configuration.Verification.Email(codeLength: 6)
        let collection1 = EmailVerificationRouteCollection(
            config: config1,
            group: ["auth1"]
        )

        let config2 = Passage.Configuration.Verification.Email(codeLength: 8)
        let collection2 = EmailVerificationRouteCollection(
            config: config2,
            group: ["auth2"]
        )

        #expect(collection1.config.codeLength != collection2.config.codeLength)
        #expect(collection1.group != collection2.group)
    }

    @Test("EmailVerificationRouteCollection can be instantiated multiple times")
    func multipleInstantiations() {
        let config = Passage.Configuration.Verification.Email()

        let collection1 = EmailVerificationRouteCollection(config: config, group: [])
        let collection2 = EmailVerificationRouteCollection(config: config, group: [])

        #expect(collection1.group == collection2.group)
    }

    // MARK: - Protocol Conformance Tests

    @Test("EmailVerificationRouteCollection conforms to RouteCollection")
    func conformsToRouteCollection() {
        let config = Passage.Configuration.Verification.Email()
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: []
        )

        let _: any RouteCollection = collection
        #expect(collection is RouteCollection)
    }

    // MARK: - Group Path Component Tests

    @Test("EmailVerificationRouteCollection with different path component types")
    func differentPathComponentTypes() {
        let config = Passage.Configuration.Verification.Email()

        // String path components
        let collection1 = EmailVerificationRouteCollection(
            config: config,
            group: ["auth", "verify"]
        )
        #expect(collection1.group.count == 2)

        // Constant path components
        let collection2 = EmailVerificationRouteCollection(
            config: config,
            group: [.constant("auth"), .constant("verify")]
        )
        #expect(collection2.group.count == 2)
    }

    @Test("EmailVerificationRouteCollection preserves group order")
    func preservesGroupOrder() {
        let config = Passage.Configuration.Verification.Email()
        let group: [PathComponent] = ["first", "second", "third"]
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: group
        )

        #expect(collection.group.count == 3)
        // Order is preserved by the array
    }

    // MARK: - Configuration Preservation Tests

    @Test("EmailVerificationRouteCollection preserves all configuration settings")
    func preservesAllConfiguration() {
        let verifyRoute = Passage.Configuration.Verification.Email.Routes.Verify(path: "verify")
        let resendRoute = Passage.Configuration.Verification.Email.Routes.Resend(path: "resend")
        let routes = Passage.Configuration.Verification.Email.Routes(
            verify: verifyRoute,
            resend: resendRoute
        )

        let config = Passage.Configuration.Verification.Email(
            routes: routes,
            codeLength: 7,
            codeExpiration: 900,
            maxAttempts: 4
        )

        let collection = EmailVerificationRouteCollection(
            config: config,
            group: ["email"]
        )

        #expect(collection.config.codeLength == 7)
        #expect(collection.config.codeExpiration == 900)
        #expect(collection.config.maxAttempts == 4)
        #expect(collection.config.routes.verify.path == ["verify"])
        #expect(collection.config.routes.resend.path == ["resend"])
        #expect(collection.group == ["email"])
    }

    @Test("EmailVerificationRouteCollection with nested path groups")
    func nestedPathGroups() {
        let config = Passage.Configuration.Verification.Email()
        let collection = EmailVerificationRouteCollection(
            config: config,
            group: ["api", "v2", "auth", "email", "verify"]
        )

        #expect(collection.group.count == 5)
    }
}
