import Vapor

extension Passage.Linking {

    struct RouteCollection: Vapor.RouteCollection, Sendable {

        let configuration: Passage.Configuration

        private var group: [PathComponent] {
            return configuration.routes.group
        }

        func boot(routes builder: any Vapor.RoutesBuilder) throws {
            let grouped = group.isEmpty ? builder : builder.grouped(configuration.routes.group)

            // Handle a form sent from the Link Account Select view
            grouped.post(configuration.federatedLogin.linkSelectPath) { req in
                do {
                    let form = try req.decodeContentAsFormOfType(req.contracts.linkAccountSelectForm)

                    try await req.linking.manual.advance(withSelectedUserId: form.selectedUserId)

                    guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.linkAccountSelect else {
                        return try await HTTPStatus.ok.encodeResponse(for: req)
                    }

                    return req.views.handleLinkAccountSelectFormSubmit(
                        of: view,
                        at: group + configuration.federatedLogin.linkVerifyPath,
                    )
                } catch {
                    guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.linkAccountSelect else {
                        throw error
                    }

                    return req.views.handleLinkAccountSelectFormFailure(
                        of: view,
                        at: group + configuration.federatedLogin.linkSelectPath,
                        with: error
                    )
                }
            }

            // Handle a form sent from the Link Account Verify view
            grouped.post(configuration.federatedLogin.linkVerifyPath) { req in
                do {
                    let form = try req.decodeContentAsFormOfType(req.contracts.linkAccountVerifyForm)

                    let user = try await req.linking.manual.complete(
                        password: form.password,
                        verificationCode: form.verificationCode,
                    )

                    guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.linkAccountVerify else {
                        let redirectURL = buildRedirectURL(
                            base: configuration.federatedLogin.redirectLocation,
                            code: try await req.tokens.createExchangeCode(for: user)
                        )
                        return req.redirect(to: redirectURL)
                    }

                    return req.views.handleLinkAccountVerifyFormSubmit(
                        of: view,
                        at: group + configuration.federatedLogin.linkVerifyPath,
                    )
                } catch {
                    guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.linkAccountVerify else {
                        return try await HTTPStatus.ok.encodeResponse(for: req)
                    }

                    return req.views.handleLinkAccountVerifyFormFailure(
                        of: view,
                        at: group + configuration.federatedLogin.linkVerifyPath,
                        with: error
                    )
                }
            }
        }

    }

}

extension Passage.Linking.RouteCollection {

    private func buildRedirectURL(base: String, code: String) -> String {
        if base.contains("?") {
            return "\(base)&code=\(code)"
        } else {
            return "\(base)?code=\(code)"
        }
    }

}
