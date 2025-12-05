import Testing
import Foundation
import Vapor
@testable import Passage

@Suite("Verification Configuration Tests")
struct VerificationConfigurationTests {

    // MARK: - Email Verification Route Tests

    @Test("Email verification verify route default")
    func emailVerifyRouteDefault() {
        let route = Passage.Configuration.Verification.Email.Routes.Verify.default
        #expect(route.path.count == 2)
        #expect(route.path[0].description == "email")
        #expect(route.path[1].description == "verify")
    }

    @Test("Email verification resend route default")
    func emailResendRouteDefault() {
        let route = Passage.Configuration.Verification.Email.Routes.Resend.default
        #expect(route.path.count == 2)
        #expect(route.path[0].description == "email")
        #expect(route.path[1].description == "resend")
    }

    @Test("Email verification routes custom paths")
    func emailRoutesCustomPaths() {
        let routes = Passage.Configuration.Verification.Email.Routes(
            verify: .init(path: "v", "email"),
            resend: .init(path: "r", "email")
        )

        #expect(routes.verify.path[0].description == "v")
        #expect(routes.verify.path[1].description == "email")
        #expect(routes.resend.path[0].description == "r")
        #expect(routes.resend.path[1].description == "email")
    }

    // MARK: - Email Verification Configuration Tests

    @Test("Email verification default configuration")
    func emailVerificationDefault() {
        let email = Passage.Configuration.Verification.Email()

        #expect(email.codeLength == 6)
        #expect(email.codeExpiration == 15 * 60)
        #expect(email.maxAttempts == 3)
    }

    @Test("Email verification custom configuration")
    func emailVerificationCustom() {
        let email = Passage.Configuration.Verification.Email(
            routes: .init(),
            codeLength: 8,
            codeExpiration: 600,
            maxAttempts: 5
        )

        #expect(email.codeLength == 8)
        #expect(email.codeExpiration == 600)
        #expect(email.maxAttempts == 5)
    }

    // MARK: - Phone Verification Route Tests

    @Test("Phone verification send code route default")
    func phoneSendCodeRouteDefault() {
        let route = Passage.Configuration.Verification.Phone.Routes.SendCode.default
        #expect(route.path.count == 2)
        #expect(route.path[0].description == "phone")
        #expect(route.path[1].description == "send-code")
    }

    @Test("Phone verification verify route default")
    func phoneVerifyRouteDefault() {
        let route = Passage.Configuration.Verification.Phone.Routes.Verify.default
        #expect(route.path.count == 2)
        #expect(route.path[0].description == "phone")
        #expect(route.path[1].description == "verify")
    }

    @Test("Phone verification resend route default")
    func phoneResendRouteDefault() {
        let route = Passage.Configuration.Verification.Phone.Routes.Resend.default
        #expect(route.path.count == 2)
        #expect(route.path[0].description == "phone")
        #expect(route.path[1].description == "resend")
    }

    @Test("Phone verification routes custom paths")
    func phoneRoutesCustomPaths() {
        let routes = Passage.Configuration.Verification.Phone.Routes(
            sendCode: .init(path: "sms", "send"),
            verify: .init(path: "sms", "verify"),
            resend: .init(path: "sms", "resend")
        )

        #expect(routes.sendCode.path[0].description == "sms")
        #expect(routes.verify.path[1].description == "verify")
        #expect(routes.resend.path[1].description == "resend")
    }

    // MARK: - Phone Verification Configuration Tests

    @Test("Phone verification default configuration")
    func phoneVerificationDefault() {
        let phone = Passage.Configuration.Verification.Phone()

        #expect(phone.codeLength == 6)
        #expect(phone.codeExpiration == 5 * 60)
        #expect(phone.maxAttempts == 3)
    }

    @Test("Phone verification custom configuration")
    func phoneVerificationCustom() {
        let phone = Passage.Configuration.Verification.Phone(
            routes: .init(),
            codeLength: 4,
            codeExpiration: 300,
            maxAttempts: 5
        )

        #expect(phone.codeLength == 4)
        #expect(phone.codeExpiration == 300)
        #expect(phone.maxAttempts == 5)
    }

    // MARK: - Verification Configuration Tests

    @Test("Verification default configuration")
    func verificationDefault() {
        let verification = Passage.Configuration.Verification()

        #expect(verification.useQueues == false)
        #expect(verification.email.codeLength == 6)
        #expect(verification.phone.codeLength == 6)
    }

    @Test("Verification with queues enabled")
    func verificationWithQueues() {
        let verification = Passage.Configuration.Verification(useQueues: true)

        #expect(verification.useQueues == true)
    }

    @Test("Verification with custom email and phone")
    func verificationCustom() {
        let verification = Passage.Configuration.Verification(
            email: .init(codeLength: 8),
            phone: .init(codeLength: 4),
            useQueues: true
        )

        #expect(verification.email.codeLength == 8)
        #expect(verification.phone.codeLength == 4)
        #expect(verification.useQueues == true)
    }

    @Test("Verification Sendable conformance")
    func verificationSendableConformance() {
        let verification: Passage.Configuration.Verification = .init()

        let _: any Sendable = verification
        let _: any Sendable = verification.email
        let _: any Sendable = verification.phone
    }

    // MARK: - Verification URL Tests

    @Test("Email verification URL construction")
    func emailVerificationURL() throws {
        let config = try Passage.Configuration(
            origin: URL(string: "https://example.com")!,
            jwt: .init(jwks: .init(json: "{}"))
        )

        let url = config.emailVerificationURL

        #expect(url.absoluteString == "https://example.com/auth/email/verify")
    }

    @Test("Email verification URL with custom routes")
    func emailVerificationURLCustomRoutes() throws {
        let config = try Passage.Configuration(
            origin: URL(string: "https://example.com")!,
            routes: .init(
                group: "api",
                register: .default
            ),
            jwt: .init(jwks: .init(json: "{}")),
            verification: .init(
                email: .init(routes: .init(verify: .init(path: "v")))
            )
        )

        let url = config.emailVerificationURL

        #expect(url.absoluteString == "https://example.com/api/v")
    }

    @Test("Phone verification URL construction")
    func phoneVerificationURL() throws {
        let config = try Passage.Configuration(
            origin: URL(string: "https://example.com")!,
            jwt: .init(jwks: .init(json: "{}"))
        )

        let url = config.phoneVerificationURL

        #expect(url.absoluteString == "https://example.com/auth/phone/verify")
    }
}
