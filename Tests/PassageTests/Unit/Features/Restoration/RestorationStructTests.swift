import Testing
import Vapor
@testable import Passage

@Suite("Restoration Struct Tests")
struct RestorationStructTests {

    // MARK: - Restoration Struct Tests

    @Test("Restoration struct is properly namespaced in Passage")
    func restorationNamespace() {
        let typeName = String(reflecting: Passage.Restoration.self)
        #expect(typeName.contains("Passage.Restoration"))
    }

    @Test("Restoration struct conforms to Sendable")
    func restorationSendable() {
        let _: any Sendable.Type = Passage.Restoration.self
        #expect(Passage.Restoration.self is Sendable.Type)
    }

    // MARK: - EmailPasswordResetCodePayload Tests

    @Test("EmailPasswordResetCodePayload initialization")
    func emailPayloadInitialization() throws {
        let url = try #require(URL(string: "https://example.com/reset?code=123&email=test@example.com"))
        let payload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: "user123",
            resetURL: url,
            resetCode: "123456"
        )

        #expect(payload.email == "test@example.com")
        #expect(payload.userId == "user123")
        #expect(payload.resetURL == url)
        #expect(payload.resetCode == "123456")
    }

    @Test("EmailPasswordResetCodePayload conforms to Codable")
    func emailPayloadCodable() throws {
        let url = try #require(URL(string: "https://example.com/reset"))
        let payload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: "user123",
            resetURL: url,
            resetCode: "ABC123"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(payload)
        #expect(!data.isEmpty)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Passage.Restoration.EmailPasswordResetCodePayload.self, from: data)

        #expect(decoded.email == payload.email)
        #expect(decoded.userId == payload.userId)
        #expect(decoded.resetURL == payload.resetURL)
        #expect(decoded.resetCode == payload.resetCode)
    }

    @Test("EmailPasswordResetCodePayload with different URLs")
    func emailPayloadDifferentURLs() throws {
        let urls = [
            "https://example.com/reset",
            "https://myapp.com/password-reset",
            "https://app.example.com/v1/reset-password"
        ]

        for urlString in urls {
            let url = try #require(URL(string: urlString))
            let payload = Passage.Restoration.EmailPasswordResetCodePayload(
                email: "test@example.com",
                userId: "user123",
                resetURL: url,
                resetCode: "123456"
            )
            #expect(payload.resetURL.absoluteString == urlString)
        }
    }

    @Test("EmailPasswordResetCodePayload round trip encoding")
    func emailPayloadRoundTrip() throws {
        let url = try #require(URL(string: "https://example.com/reset?code=XYZ&email=user@example.com"))
        let original = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "user@example.com",
            userId: "user456",
            resetURL: url,
            resetCode: "XYZ789"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Passage.Restoration.EmailPasswordResetCodePayload.self, from: data)

        #expect(decoded.email == original.email)
        #expect(decoded.userId == original.userId)
        #expect(decoded.resetURL == original.resetURL)
        #expect(decoded.resetCode == original.resetCode)
    }

    @Test("EmailPasswordResetCodePayload JSON encoding format")
    func emailPayloadJSONFormat() throws {
        let url = try #require(URL(string: "https://example.com/reset"))
        let payload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: "user123",
            resetURL: url,
            resetCode: "123456"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(payload)
        let json = String(data: data, encoding: .utf8)

        #expect(json != nil)
        #expect(json!.contains("\"email\""))
        #expect(json!.contains("\"userId\""))
        #expect(json!.contains("\"resetURL\""))
        #expect(json!.contains("\"resetCode\""))
    }

    // MARK: - PhonePasswordResetCodePayload Tests

    @Test("PhonePasswordResetCodePayload initialization")
    func phonePayloadInitialization() {
        let payload = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+1234567890",
            code: "123456",
            userId: "user123"
        )

        #expect(payload.phone == "+1234567890")
        #expect(payload.code == "123456")
        #expect(payload.userId == "user123")
    }

    @Test("PhonePasswordResetCodePayload conforms to Codable")
    func phonePayloadCodable() throws {
        let payload = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+1234567890",
            code: "ABC123",
            userId: "user123"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(payload)
        #expect(!data.isEmpty)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Passage.Restoration.PhonePasswordResetCodePayload.self, from: data)

        #expect(decoded.phone == payload.phone)
        #expect(decoded.code == payload.code)
        #expect(decoded.userId == payload.userId)
    }

    @Test("PhonePasswordResetCodePayload with different phone formats", arguments: [
        "+1234567890",
        "+44 7700 900000",
        "+81 90-1234-5678",
        "555-0123"
    ])
    func phonePayloadPhoneFormats(phone: String) {
        let payload = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: phone,
            code: "123456",
            userId: "user123"
        )
        #expect(payload.phone == phone)
    }

    @Test("PhonePasswordResetCodePayload round trip encoding")
    func phonePayloadRoundTrip() throws {
        let original = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+19876543210",
            code: "XYZ789",
            userId: "user789"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Passage.Restoration.PhonePasswordResetCodePayload.self, from: data)

        #expect(decoded.phone == original.phone)
        #expect(decoded.code == original.code)
        #expect(decoded.userId == original.userId)
    }

    @Test("PhonePasswordResetCodePayload JSON encoding format")
    func phonePayloadJSONFormat() throws {
        let payload = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+1234567890",
            code: "123456",
            userId: "user123"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(payload)
        let json = String(data: data, encoding: .utf8)

        #expect(json != nil)
        #expect(json!.contains("\"phone\""))
        #expect(json!.contains("\"code\""))
        #expect(json!.contains("\"userId\""))
    }

    // MARK: - Payload Independence Tests

    @Test("Email and phone payloads are independent")
    func payloadsIndependent() throws {
        let url = try #require(URL(string: "https://example.com/reset"))
        let emailPayload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: "user1",
            resetURL: url,
            resetCode: "ABC123"
        )

        let phonePayload = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+1234567890",
            code: "XYZ789",
            userId: "user2"
        )

        #expect(emailPayload.userId != phonePayload.userId)
        #expect(emailPayload.resetCode != phonePayload.code)
    }

    @Test("Multiple email payloads can coexist")
    func multipleEmailPayloads() throws {
        let url1 = try #require(URL(string: "https://example.com/reset1"))
        let url2 = try #require(URL(string: "https://example.com/reset2"))

        let payload1 = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "user1@example.com",
            userId: "user1",
            resetURL: url1,
            resetCode: "CODE1"
        )

        let payload2 = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "user2@example.com",
            userId: "user2",
            resetURL: url2,
            resetCode: "CODE2"
        )

        #expect(payload1.email != payload2.email)
        #expect(payload1.userId != payload2.userId)
        #expect(payload1.resetCode != payload2.resetCode)
    }

    @Test("Multiple phone payloads can coexist")
    func multiplePhonePayloads() {
        let payload1 = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+1234567890",
            code: "CODE1",
            userId: "user1"
        )

        let payload2 = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+9876543210",
            code: "CODE2",
            userId: "user2"
        )

        #expect(payload1.phone != payload2.phone)
        #expect(payload1.code != payload2.code)
        #expect(payload1.userId != payload2.userId)
    }

    // MARK: - Reset Code Format Tests

    @Test("EmailPasswordResetCodePayload with different code formats", arguments: [
        "123456",
        "ABC123",
        "A1B2C3",
        "000000"
    ])
    func emailPayloadCodeFormats(code: String) throws {
        let url = try #require(URL(string: "https://example.com/reset"))
        let payload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: "user123",
            resetURL: url,
            resetCode: code
        )
        #expect(payload.resetCode == code)
    }

    @Test("PhonePasswordResetCodePayload with different code formats", arguments: [
        "123456",
        "ABC123",
        "A1B2C3",
        "000000"
    ])
    func phonePayloadCodeFormats(code: String) {
        let payload = Passage.Restoration.PhonePasswordResetCodePayload(
            phone: "+1234567890",
            code: code,
            userId: "user123"
        )
        #expect(payload.code == code)
    }

    // MARK: - URL Query Parameters Tests

    @Test("EmailPasswordResetCodePayload with URL containing query parameters")
    func emailPayloadWithQueryParams() throws {
        let url = try #require(URL(string: "https://example.com/reset?code=123&email=test@example.com&token=xyz"))
        let payload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: "user123",
            resetURL: url,
            resetCode: "123456"
        )

        #expect(payload.resetURL.query != nil)
        #expect(payload.resetURL.query!.contains("code=123"))
        #expect(payload.resetURL.query!.contains("email="))
    }

    @Test("EmailPasswordResetCodePayload with complex reset URL")
    func emailPayloadComplexURL() throws {
        let url = try #require(URL(string: "https://app.example.com/auth/reset-password?step=verify&token=abc123&redirect=/dashboard"))
        let payload = Passage.Restoration.EmailPasswordResetCodePayload(
            email: "test@example.com",
            userId: "user123",
            resetURL: url,
            resetCode: "123456"
        )

        #expect(payload.resetURL.host == "app.example.com")
        #expect(payload.resetURL.path == "/auth/reset-password")
        #expect(payload.resetURL.query != nil)
    }

    // MARK: - Nested Type Tests

    @Test("EmailPasswordResetCodePayload is nested in Restoration")
    func emailPayloadNesting() {
        let typeName = String(reflecting: Passage.Restoration.EmailPasswordResetCodePayload.self)
        #expect(typeName.contains("Passage.Restoration.EmailPasswordResetCodePayload"))
    }

    @Test("PhonePasswordResetCodePayload is nested in Restoration")
    func phonePayloadNesting() {
        let typeName = String(reflecting: Passage.Restoration.PhonePasswordResetCodePayload.self)
        #expect(typeName.contains("Passage.Restoration.PhonePasswordResetCodePayload"))
    }

    @Test("SendEmailPasswordResetCodeJob is nested in Restoration")
    func sendEmailJobNesting() {
        let typeName = String(reflecting: Passage.Restoration.SendEmailPasswordResetCodeJob.self)
        #expect(typeName.contains("Passage.Restoration.SendEmailPasswordResetCodeJob"))
    }

    @Test("SendPhonePasswordResetCodeJob is nested in Restoration")
    func sendPhoneJobNesting() {
        let typeName = String(reflecting: Passage.Restoration.SendPhonePasswordResetCodeJob.self)
        #expect(typeName.contains("Passage.Restoration.SendPhonePasswordResetCodeJob"))
    }
}
