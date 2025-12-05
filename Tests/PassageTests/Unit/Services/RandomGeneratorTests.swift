import Testing
import Foundation
@testable import Passage

@Suite("RandomGenerator Tests")
struct RandomGeneratorTests {

    // MARK: - DefaultRandomGenerator Tests

    @Test("DefaultRandomGenerator generateRandomString creates non-empty string")
    func generateRandomStringNonEmpty() {
        let generator = DefaultRandomGenerator()
        let randomString = generator.generateRandomString(count: 16)

        #expect(!randomString.isEmpty)
    }

    @Test("DefaultRandomGenerator generateRandomString with different counts", arguments: [
        8, 16, 32, 64
    ])
    func generateRandomStringDifferentCounts(count: Int) {
        let generator = DefaultRandomGenerator()
        let randomString = generator.generateRandomString(count: count)

        // Base64 encoded strings have length roughly 4/3 of input bytes
        #expect(randomString.count > 0)
    }

    @Test("DefaultRandomGenerator generateRandomString produces different values")
    func generateRandomStringUnique() {
        let generator = DefaultRandomGenerator()
        let string1 = generator.generateRandomString(count: 16)
        let string2 = generator.generateRandomString(count: 16)

        #expect(string1 != string2)
    }

    @Test("DefaultRandomGenerator generateOpaqueToken creates non-empty token")
    func generateOpaqueTokenNonEmpty() {
        let generator = DefaultRandomGenerator()
        let token = generator.generateOpaqueToken()

        #expect(!token.isEmpty)
    }

    @Test("DefaultRandomGenerator generateOpaqueToken produces different values")
    func generateOpaqueTokenUnique() {
        let generator = DefaultRandomGenerator()
        let token1 = generator.generateOpaqueToken()
        let token2 = generator.generateOpaqueToken()

        #expect(token1 != token2)
    }

    @Test("DefaultRandomGenerator hashOpaqueToken creates consistent hash")
    func hashOpaqueTokenConsistent() {
        let generator = DefaultRandomGenerator()
        let token = "test_token"
        let hash1 = generator.hashOpaqueToken(token: token)
        let hash2 = generator.hashOpaqueToken(token: token)

        #expect(hash1 == hash2)
    }

    @Test("DefaultRandomGenerator hashOpaqueToken creates different hashes for different tokens")
    func hashOpaqueTokenDifferentInputs() {
        let generator = DefaultRandomGenerator()
        let hash1 = generator.hashOpaqueToken(token: "token1")
        let hash2 = generator.hashOpaqueToken(token: "token2")

        #expect(hash1 != hash2)
    }

    @Test("DefaultRandomGenerator hashOpaqueToken produces 64-character hex string")
    func hashOpaqueTokenLength() {
        let generator = DefaultRandomGenerator()
        let hash = generator.hashOpaqueToken(token: "test")

        // SHA256 produces 64 hex characters
        #expect(hash.count == 64)
    }

    @Test("DefaultRandomGenerator hashOpaqueToken produces hex characters only")
    func hashOpaqueTokenHexOnly() {
        let generator = DefaultRandomGenerator()
        let hash = generator.hashOpaqueToken(token: "test")

        let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdef")
        let hashCharacterSet = CharacterSet(charactersIn: hash)
        #expect(hashCharacterSet.isSubset(of: hexCharacterSet))
    }

    @Test("DefaultRandomGenerator generateVerificationCode creates code of correct length")
    func generateVerificationCodeLength() {
        let generator = DefaultRandomGenerator()
        let code = generator.generateVerificationCode(length: 6)

        #expect(code.count == 6)
    }

    @Test("DefaultRandomGenerator generateVerificationCode with different lengths", arguments: [
        4, 6, 8, 10
    ])
    func generateVerificationCodeDifferentLengths(length: Int) {
        let generator = DefaultRandomGenerator()
        let code = generator.generateVerificationCode(length: length)

        #expect(code.count == length)
    }

    @Test("DefaultRandomGenerator generateVerificationCode produces different values")
    func generateVerificationCodeUnique() {
        let generator = DefaultRandomGenerator()
        let code1 = generator.generateVerificationCode(length: 6)
        let code2 = generator.generateVerificationCode(length: 6)

        // Very high probability codes are different
        #expect(code1 != code2)
    }

    @Test("DefaultRandomGenerator generateVerificationCode excludes confusing characters")
    func generateVerificationCodeNoConfusingChars() {
        let generator = DefaultRandomGenerator()
        let code = generator.generateVerificationCode(length: 100) // Large sample

        // Should not contain 0, O, 1, I (based on actual implementation)
        #expect(!code.contains("0"))
        #expect(!code.contains("O"))
        #expect(!code.contains("1"))
        #expect(!code.contains("I"))
    }

    @Test("DefaultRandomGenerator generateVerificationCode uses alphanumeric characters")
    func generateVerificationCodeAlphanumeric() {
        let generator = DefaultRandomGenerator()
        let code = generator.generateVerificationCode(length: 100)

        let allowedCharacters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        for char in code {
            #expect(allowedCharacters.contains(char))
        }
    }

    // MARK: - Protocol Conformance Tests

    @Test("DefaultRandomGenerator conforms to RandomGenerator protocol")
    func defaultRandomGeneratorConformsToProtocol() {
        let generator: any Passage.RandomGenerator = DefaultRandomGenerator()
        #expect(generator is DefaultRandomGenerator)
    }

    @Test("RandomGenerator protocol conforms to Sendable")
    func randomGeneratorProtocolIsSendable() {
        let generator: any Sendable = DefaultRandomGenerator()
        #expect(generator is DefaultRandomGenerator)
    }

    // MARK: - Custom RandomGenerator Implementation Tests

    struct CustomRandomGenerator: Passage.RandomGenerator {
        func generateRandomString(count: Int) -> String { "custom_random" }
        func generateOpaqueToken() -> String { "custom_token" }
        func hashOpaqueToken(token: String) -> String { "custom_hash" }
        func generateVerificationCode(length: Int) -> String { String(repeating: "X", count: length) }
    }

    @Test("Custom RandomGenerator implementation can be used")
    func customRandomGeneratorImplementation() {
        let generator: any Passage.RandomGenerator = CustomRandomGenerator()

        #expect(generator.generateRandomString(count: 10) == "custom_random")
        #expect(generator.generateOpaqueToken() == "custom_token")
        #expect(generator.hashOpaqueToken(token: "test") == "custom_hash")
        #expect(generator.generateVerificationCode(length: 6) == "XXXXXX")
    }

    // MARK: - Edge Cases Tests

    @Test("DefaultRandomGenerator generateVerificationCode with length 0")
    func generateVerificationCodeZeroLength() {
        let generator = DefaultRandomGenerator()
        let code = generator.generateVerificationCode(length: 0)

        #expect(code.isEmpty)
    }

    @Test("DefaultRandomGenerator generateRandomString with count 0")
    func generateRandomStringZeroCount() {
        let generator = DefaultRandomGenerator()
        let randomString = generator.generateRandomString(count: 0)

        // Base64 of empty data is empty string
        #expect(randomString.isEmpty)
    }

    @Test("DefaultRandomGenerator hashOpaqueToken with empty string")
    func hashOpaqueTokenEmptyString() {
        let generator = DefaultRandomGenerator()
        let hash = generator.hashOpaqueToken(token: "")

        // Even empty string should produce valid SHA256 hash
        #expect(hash.count == 64)
    }

    // MARK: - Integration Tests

    @Test("DefaultRandomGenerator token and hash workflow")
    func tokenAndHashWorkflow() {
        let generator = DefaultRandomGenerator()

        // Generate token
        let token = generator.generateOpaqueToken()
        #expect(!token.isEmpty)

        // Hash the token
        let hash = generator.hashOpaqueToken(token: token)
        #expect(hash.count == 64)

        // Same token produces same hash
        let hash2 = generator.hashOpaqueToken(token: token)
        #expect(hash == hash2)
    }

    @Test("DefaultRandomGenerator verification code workflow")
    func verificationCodeWorkflow() {
        let generator = DefaultRandomGenerator()

        // Generate code
        let code = generator.generateVerificationCode(length: 6)
        #expect(code.count == 6)

        // Hash the code
        let hash = generator.hashOpaqueToken(token: code)
        #expect(hash.count == 64)

        // Verify same code produces same hash
        let hash2 = generator.hashOpaqueToken(token: code)
        #expect(hash == hash2)
    }
}
