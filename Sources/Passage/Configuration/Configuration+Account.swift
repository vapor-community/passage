public extension Passage.Configuration {

    struct Account: Sendable {
        let password: Bool

        public init(password: Bool = true) {
            self.password = password
        }
    }
}
