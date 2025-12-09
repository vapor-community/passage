// MARK: - Session

public extension Passage.Configuration {

    struct Sessions: Sendable {
        let enabled: Bool

        public init(
            enabled: Bool = false
        ) {
            self.enabled = enabled
        }
    }
}
