public struct Credential: Sendable {

    public enum Kind: String, Sendable {
        case password
    }

    public let kind: Kind
    public let secret: String
}

extension Credential {
    public static func password(_ passwordHash: String) -> Credential {
        return Credential(kind: .password, secret: passwordHash)
    }
}
