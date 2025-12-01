//
//  Tokens.swift
//  passten
//
//  Created by Max Rozdobudko on 11/27/25.
//

import Vapor
import JWTKit

// MARK: - ID Token

// TODO: For future usage
struct IdToken: UserInfo, Sendable {

    // Standard claims
    let subject: SubjectClaim
    let expiration: ExpirationClaim
    let issuedAt: IssuedAtClaim
    let issuer: IssuerClaim?
    let audience: AudienceClaim?

    // Identity claims
    let email: String?
    let phone: String?
}

extension IdToken: JWTPayload {

    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case issuedAt = "iat"
        case issuer = "iss"
        case audience = "aud"
        case email
        case phone
    }

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }
}

// MARK: - Access Token

struct AccessToken: Sendable {

    // Standard claims
    let subject: SubjectClaim
    let expiration: ExpirationClaim
    let issuedAt: IssuedAtClaim
    let issuer: IssuerClaim?
    let audience: AudienceClaim?

    // Authorization claims
    let scope: String?

    init(
        userId: String,
        issuedAt: Date = .now,
        expiresAt: Date,
        issuer: String?,
        audience: String?,
        scope: String?
    ) {
        self.subject = SubjectClaim(value: userId)
        self.issuedAt = IssuedAtClaim(value: issuedAt)
        self.expiration = ExpirationClaim(value: expiresAt)
        self.issuer = issuer.map { IssuerClaim(value: $0) }
        self.audience = audience.map { AudienceClaim(value: $0) }
        self.scope = scope
    }
}

extension AccessToken: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case issuedAt = "iat"
        case issuer = "iss"
        case audience = "aud"
        case scope
    }

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }
}

// MARK: - Refresh Token

protocol RefreshToken: Sendable {
    associatedtype Id: CustomStringConvertible, Codable, Hashable, Sendable
    associatedtype AssociatedUser: User

    var id: Id? { get }

    var user: AssociatedUser { get }

    var tokenHash: String { get }

    var expiresAt: Date { get }

    var revokedAt: Date? { get }

    var replacedBy: Id? { get }
}

extension RefreshToken {

    var isExpired: Bool {
        expiresAt < .now
    }

    var isRevoked: Bool {
        revokedAt != nil
    }

    var isValid: Bool {
        !isExpired && !isRevoked
    }

}
