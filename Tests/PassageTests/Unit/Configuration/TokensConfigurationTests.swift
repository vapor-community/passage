import Testing
import Foundation
@testable import Passage

@Suite("Tokens Configuration Tests")
struct TokensConfigurationTests {

    // MARK: - IdToken Configuration Tests

    @Test("ID token time to live", arguments: [
        (3600.0, "1 hour - default"),
        (300.0, "5 minutes"),
        (1800.0, "30 minutes"),
        (7200.0, "2 hours")
    ])
    func idTokenTTL(ttl: TimeInterval, _: String) {
        let idToken = Passage.Configuration.Tokens.IdToken(timeToLive: ttl)
        #expect(idToken.timeToLive == ttl)
    }

    // MARK: - AccessToken Configuration Tests

    @Test("Access token time to live", arguments: [
        (900.0, "15 minutes - default"),
        (300.0, "5 minutes"),
        (1800.0, "30 minutes"),
        (3600.0, "1 hour")
    ])
    func accessTokenTTL(ttl: TimeInterval, _: String) {
        let accessToken = Passage.Configuration.Tokens.AccessToken(timeToLive: ttl)
        #expect(accessToken.timeToLive == ttl)
    }

    // MARK: - RefreshToken Configuration Tests

    @Test("Refresh token time to live", arguments: [
        (604800.0, "7 days - default"),
        (86400.0, "1 day"),
        (2592000.0, "30 days")
    ])
    func refreshTokenTTL(ttl: TimeInterval, _: String) {
        let refreshToken = Passage.Configuration.Tokens.RefreshToken(timeToLive: ttl)
        #expect(refreshToken.timeToLive == ttl)
    }

    // MARK: - Tokens Configuration Tests

    @Test("Tokens default configuration")
    func tokensDefaultConfiguration() {
        let tokens = Passage.Configuration.Tokens()

        #expect(tokens.issuer == nil)
        #expect(tokens.idToken.timeToLive == 1 * 3600)
        #expect(tokens.accessToken.timeToLive == 15 * 60)
        #expect(tokens.refreshToken.timeToLive == 7 * 24 * 3600)
    }

    @Test("Tokens configuration with issuer")
    func tokensWithIssuer() {
        let tokens = Passage.Configuration.Tokens(issuer: "https://example.com")

        #expect(tokens.issuer == "https://example.com")
    }

    @Test("Tokens configuration with custom TTLs")
    func tokensWithCustomTTLs() {
        let tokens = Passage.Configuration.Tokens(
            issuer: "https://auth.example.com",
            idToken: .init(timeToLive: 7200),
            accessToken: .init(timeToLive: 600),
            refreshToken: .init(timeToLive: 2592000)
        )

        #expect(tokens.issuer == "https://auth.example.com")
        #expect(tokens.idToken.timeToLive == 7200)
        #expect(tokens.accessToken.timeToLive == 600)
        #expect(tokens.refreshToken.timeToLive == 2592000)
    }

    @Test("Tokens Sendable conformance")
    func tokensSendableConformance() {
        let tokens: Passage.Configuration.Tokens = .init()

        // Verify all nested types are Sendable
        let _: any Sendable = tokens
        let _: any Sendable = tokens.idToken
        let _: any Sendable = tokens.accessToken
        let _: any Sendable = tokens.refreshToken
    }
}
