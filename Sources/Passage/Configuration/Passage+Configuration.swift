import Foundation
import Vapor

extension Passage {

    public struct Configuration: Sendable {
        let origin: URL
        let routes: Routes
        let tokens: Tokens
        let jwt: JWT
        let passwordless: Passwordless
        let verification: Verification
        let restoration: Restoration
        let oauth: FederatedLogin
        let views: Views

        public init(
            origin: URL,
            routes: Routes = .init(),
            tokens: Tokens = .init(),
            jwt: JWT? = nil,
            passwordless: Passwordless = .init(),
            verification: Verification = .init(),
            restoration: Restoration = .init(),
            oauth: FederatedLogin = .init(routes: .init(), providers: []),
            views: Views = .init()
        ) throws {
            self.origin = origin
            self.routes = routes
            self.tokens = tokens
            self.jwt = try jwt ?? JWT(jwks: try .fileFromEnvironment())
            self.passwordless = passwordless
            self.verification = verification
            self.restoration = restoration
            self.oauth = oauth
            self.views = views
        }
    }

}





