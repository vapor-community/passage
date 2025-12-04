import Passage
import Vapor

// MARK: - OnlyForTest Federated Login Mock

public extension Passage.OnlyForTest {

    struct MockFederatedLoginService: Passage.FederatedLoginService {

        let callback: (@Sendable (
            _ provider: Passage.FederatedLogin.Provider,
            _ request: Request,
            _ payload: String
        ) async throws -> Void)?

        public init(
            callback: (@Sendable (
                _ provider: Passage.FederatedLogin.Provider,
                _ request: Request,
                _ payload: String
            ) async throws -> Void)? = nil
        ) {
            self.callback = callback
        }

        public func register(
            router: any RoutesBuilder,
            origin: URL,
            group: [PathComponent],
            config: Passage.Configuration.FederatedLogin,
            completion: @escaping @Sendable (
                _ provider: Passage.FederatedLogin.Provider,
                _ request: Request,
                _ payload: String
            ) async throws -> some AsyncResponseEncodable
        ) throws {
            
        }
    }

}
