import Vapor

struct ViewsRouteCollection: RouteCollection {

    let config: Passage.Configuration.Views
    let routes: Passage.Configuration.Routes
    let restoration: Passage.Configuration.Restoration
    let group: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = group.isEmpty ? builder : builder.grouped(group)

        if let view = config.register {
            grouped.get(routes.register.path) { req in
                try await req.views.renderRegisterView()
            }
        }

        if let view = config.login {
            grouped.get(routes.login.path) { req in
                try await req.views.renderLoginView()
            }
        }

        if let view = config.passwordResetRequest {
            grouped.get(restoration.email.routes.request.path) { req in
                try await req.views.renderResetPasswordRequestView(
                    for: .email
                )
            }
            grouped.get(restoration.phone.routes.request.path) { req in
                try await req.views.renderResetPasswordRequestView(
                    for: .phone
                )
            }
        }

        if let view = config.passwordResetConfirm {
            grouped.get(restoration.email.routes.verify.path) { req in
                try await req.views.renderResetPasswordConfirmView(
                    for: .email
                )
            }
            grouped.get(restoration.phone.routes.verify.path) { req in
                try await req.views.renderResetPasswordConfirmView(
                    for: .phone
                )
            }
        }
    }

}
