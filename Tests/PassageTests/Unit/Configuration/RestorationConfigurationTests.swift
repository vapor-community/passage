import Testing
import Foundation
import Vapor
@testable import Passage

@Suite("Restoration Configuration Tests")
struct RestorationConfigurationTests {

    // MARK: - Email Restoration Route Tests

    @Test("Email restoration request route default")
    func emailRequestRouteDefault() {
        let route = Passage.Configuration.Restoration.Email.Routes.Request.default
        #expect(route.path.count == 3)
        #expect(route.path[0].description == "password")
        #expect(route.path[1].description == "reset")
        #expect(route.path[2].description == "email")
    }

    @Test("Email restoration verify route default")
    func emailVerifyRouteDefault() {
        let route = Passage.Configuration.Restoration.Email.Routes.Verify.default
        #expect(route.path.count == 4)
        #expect(route.path[0].description == "password")
        #expect(route.path[1].description == "reset")
        #expect(route.path[2].description == "email")
        #expect(route.path[3].description == "verify")
    }

    @Test("Email restoration resend route default")
    func emailResendRouteDefault() {
        let route = Passage.Configuration.Restoration.Email.Routes.Resend.default
        #expect(route.path.count == 4)
        #expect(route.path[0].description == "password")
        #expect(route.path[1].description == "reset")
        #expect(route.path[2].description == "email")
        #expect(route.path[3].description == "resend")
    }

    @Test("Email restoration routes custom paths")
    func emailRoutesCustomPaths() {
        let routes = Passage.Configuration.Restoration.Email.Routes(
            request: .init(path: "forgot"),
            verify: .init(path: "reset"),
            resend: .init(path: "resend")
        )

        #expect(routes.request.path[0].description == "forgot")
        #expect(routes.verify.path[0].description == "reset")
        #expect(routes.resend.path[0].description == "resend")
    }

    // MARK: - Email Restoration Configuration Tests

    @Test("Email restoration default configuration")
    func emailRestorationDefault() {
        let email = Passage.Configuration.Restoration.Email()

        #expect(email.codeLength == 6)
        #expect(email.codeExpiration == 15 * 60)
        #expect(email.maxAttempts == 3)
    }

    @Test("Email restoration custom configuration")
    func emailRestorationCustom() {
        let email = Passage.Configuration.Restoration.Email(
            routes: .init(),
            codeLength: 8,
            codeExpiration: 1800,
            maxAttempts: 5
        )

        #expect(email.codeLength == 8)
        #expect(email.codeExpiration == 1800)
        #expect(email.maxAttempts == 5)
    }

    // MARK: - Phone Restoration Route Tests

    @Test("Phone restoration request route default")
    func phoneRequestRouteDefault() {
        let route = Passage.Configuration.Restoration.Phone.Routes.Request.default
        #expect(route.path.count == 3)
        #expect(route.path[0].description == "password")
        #expect(route.path[1].description == "reset")
        #expect(route.path[2].description == "phone")
    }

    @Test("Phone restoration verify route default")
    func phoneVerifyRouteDefault() {
        let route = Passage.Configuration.Restoration.Phone.Routes.Verify.default
        #expect(route.path.count == 4)
        #expect(route.path[0].description == "password")
        #expect(route.path[1].description == "reset")
        #expect(route.path[2].description == "phone")
        #expect(route.path[3].description == "verify")
    }

    @Test("Phone restoration resend route default")
    func phoneResendRouteDefault() {
        let route = Passage.Configuration.Restoration.Phone.Routes.Resend.default
        #expect(route.path.count == 4)
        #expect(route.path[0].description == "password")
        #expect(route.path[1].description == "reset")
        #expect(route.path[2].description == "phone")
        #expect(route.path[3].description == "resend")
    }

    @Test("Phone restoration routes custom paths")
    func phoneRoutesCustomPaths() {
        let routes = Passage.Configuration.Restoration.Phone.Routes(
            request: .init(path: "forgot", "sms"),
            verify: .init(path: "reset", "sms"),
            resend: .init(path: "resend", "sms")
        )

        #expect(routes.request.path[1].description == "sms")
        #expect(routes.verify.path[1].description == "sms")
        #expect(routes.resend.path[1].description == "sms")
    }

    // MARK: - Phone Restoration Configuration Tests

    @Test("Phone restoration default configuration")
    func phoneRestorationDefault() {
        let phone = Passage.Configuration.Restoration.Phone()

        #expect(phone.codeLength == 6)
        #expect(phone.codeExpiration == 5 * 60)
        #expect(phone.maxAttempts == 3)
    }

    @Test("Phone restoration custom configuration")
    func phoneRestorationCustom() {
        let phone = Passage.Configuration.Restoration.Phone(
            routes: .init(),
            codeLength: 4,
            codeExpiration: 300,
            maxAttempts: 5
        )

        #expect(phone.codeLength == 4)
        #expect(phone.codeExpiration == 300)
        #expect(phone.maxAttempts == 5)
    }

    // MARK: - Restoration Configuration Tests

    @Test("Restoration default configuration")
    func restorationDefault() {
        let restoration = Passage.Configuration.Restoration()

        #expect(restoration.preferredDelivery == .email)
        #expect(restoration.useQueues == false)
        #expect(restoration.email.codeLength == 6)
        #expect(restoration.phone.codeLength == 6)
    }

    @Test("Restoration with phone preferred delivery")
    func restorationPhonePreferred() {
        let restoration = Passage.Configuration.Restoration(preferredDelivery: .phone)

        #expect(restoration.preferredDelivery == .phone)
    }

    @Test("Restoration with queues enabled")
    func restorationWithQueues() {
        let restoration = Passage.Configuration.Restoration(useQueues: true)

        #expect(restoration.useQueues == true)
    }

    @Test("Restoration with custom email and phone")
    func restorationCustom() {
        let restoration = Passage.Configuration.Restoration(
            preferredDelivery: .phone,
            email: .init(codeLength: 8),
            phone: .init(codeLength: 4),
            useQueues: true
        )

        #expect(restoration.preferredDelivery == .phone)
        #expect(restoration.email.codeLength == 8)
        #expect(restoration.phone.codeLength == 4)
        #expect(restoration.useQueues == true)
    }

    @Test("Restoration Sendable conformance")
    func restorationSendableConformance() {
        let restoration: Passage.Configuration.Restoration = .init()

        let _: any Sendable = restoration
        let _: any Sendable = restoration.email
        let _: any Sendable = restoration.phone
    }

    // MARK: - Restoration URL Tests

    @Test("Email password reset URL construction")
    func emailPasswordResetURL() throws {
        let config = try Passage.Configuration(
            origin: URL(string: "https://example.com")!,
            jwt: .init(jwks: .init(json: "{}"))
        )

        let url = config.emailPasswordResetURL

        #expect(url.absoluteString == "https://example.com/auth/password/reset/email/verify")
    }

    @Test("Email password reset link URL with code and email")
    func emailPasswordResetLinkURL() throws {
        let config = try Passage.Configuration(
            origin: URL(string: "https://example.com")!,
            jwt: .init(jwks: .init(json: "{}"))
        )

        let url = config.emailPasswordResetLinkURL(code: "123456", email: "test@example.com")

        #expect(url.absoluteString.contains("code=123456"))
        #expect(url.absoluteString.contains("email=test@example.com"))
        #expect(url.absoluteString.hasPrefix("https://example.com/auth/password/reset/email/verify"))
    }

    @Test("Phone password reset URL construction")
    func phonePasswordResetURL() throws {
        let config = try Passage.Configuration(
            origin: URL(string: "https://example.com")!,
            jwt: .init(jwks: .init(json: "{}"))
        )

        let url = config.phonePasswordResetURL

        #expect(url.absoluteString == "https://example.com/auth/password/reset/phone/verify")
    }

    @Test("Restoration URLs with custom routes")
    func restorationURLsCustomRoutes() throws {
        let config = try Passage.Configuration(
            origin: URL(string: "https://example.com")!,
            routes: .init(group: "api"),
            jwt: .init(jwks: .init(json: "{}")),
            restoration: .init(
                email: .init(routes: .init(verify: .init(path: "reset")))
            )
        )

        let url = config.emailPasswordResetURL

        #expect(url.absoluteString == "https://example.com/api/reset")
    }
}
