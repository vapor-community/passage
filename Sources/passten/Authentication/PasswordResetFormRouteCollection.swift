//
//  PasswordResetFormRouteCollection.swift
//  passten
//
//  Created by Max Rozdobudko on 12/01/25.
//

import Vapor
import Leaf

/// Route collection that serves a web form for password reset.
/// This provides a default UI for users clicking reset links in emails.
struct PasswordResetFormRouteCollection: RouteCollection {

    let config: Identity.Configuration
    let groupPath: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        guard config.restoration.email.webForm.enabled else { return }

        let grouped = builder.grouped(groupPath)
        let formPath = config.restoration.email.webForm.route.path

        // GET - Display the form
        grouped.get(formPath, use: showForm)

        // POST - Handle form submission
        grouped.post(formPath, use: handleSubmit)
    }

    // GET /auth/password/reset?code=ABC123&email=user@example.com
    @Sendable
    func showForm(_ req: Request) async throws -> View {
        let code = req.query[String.self, at: "code"] ?? ""
        let email = req.query[String.self, at: "email"] ?? ""
        let error = req.query[String.self, at: "error"]
        let success = req.query[String.self, at: "success"]

        let context = PasswordResetFormContext(
            code: code,
            email: email,
            error: error,
            success: success,
            apiEndpoint: config.emailPasswordResetURL.absoluteString
        )

        return try await req.view.render(config.restoration.email.webForm.template, context)
    }

    // POST /auth/password/reset
    @Sendable
    func handleSubmit(_ req: Request) async throws -> Response {
        let form = try req.content.decode(PasswordResetFormData.self)

        // Validate passwords match
        guard form.newPassword == form.confirmPassword else {
            return req.redirect(to: buildFormURL(email: form.email, code: form.code, error: "Passwords do not match"))
        }

        do {
            let passwordHash = try Bcrypt.hash(form.newPassword)
            let identifier = Identifier(kind: .email, value: form.email)
            try await req.restoration.verifyAndResetPassword(
                identifier: identifier,
                code: form.code,
                newPasswordHash: passwordHash
            )
            return req.redirect(to: buildFormURL(email: form.email, success: "Password reset successfully. You can now log in with your new password."))
        } catch let error as AuthenticationError {
            return req.redirect(to: buildFormURL(email: form.email, code: form.code, error: error.reason))
        } catch {
            return req.redirect(to: buildFormURL(email: form.email, code: form.code, error: "An unexpected error occurred. Please try again."))
        }
    }

    private func buildFormURL(email: String, code: String = "", error: String? = nil, success: String? = nil) -> String {
        var components = URLComponents()
        components.path = "/" + (groupPath + config.restoration.email.webForm.route.path).string
        var items = [URLQueryItem(name: "email", value: email)]
        if !code.isEmpty { items.append(URLQueryItem(name: "code", value: code)) }
        if let error { items.append(URLQueryItem(name: "error", value: error)) }
        if let success { items.append(URLQueryItem(name: "success", value: success)) }
        components.queryItems = items
        return components.string ?? "/"
    }
}

// MARK: - Form Data

struct PasswordResetFormData: Content {
    let email: String
    let code: String
    let newPassword: String
    let confirmPassword: String
}

// MARK: - Form Context

struct PasswordResetFormContext: Content {
    let code: String
    let email: String
    let error: String?
    let success: String?
    let apiEndpoint: String
}
