import Testing
import Vapor
import NIOCore
@testable import Passage

@Suite("Form Detection Tests")
struct FormDetectionTests {

    // MARK: - isFormSubmission Tests

    @Test("isFormSubmission returns true for application/x-www-form-urlencoded")
    func formSubmissionWithURLEncoded() async throws {
        try await withApp { app in
            let req = Request(
                application: app,
                method: .POST,
                url: .init(string: "/test"),
                on: app.eventLoopGroup.any()
            )
            req.headers.contentType = .urlEncodedForm
            #expect(req.isFormSubmission == true)
        }
    }

    @Test("isFormSubmission returns true for multipart/form-data")
    func formSubmissionWithMultipart() async throws {
        try await withApp { app in
            let req = Request(
                application: app,
                method: .POST,
                url: .init(string: "/test"),
                on: app.eventLoopGroup.any()
            )
            req.headers.contentType = .formData
            #expect(req.isFormSubmission == true)
        }
    }

    @Test("isFormSubmission returns false for application/json")
    func formSubmissionWithJSON() async throws {
        try await withApp { app in
            let req = Request(
                application: app,
                method: .POST,
                url: .init(string: "/test"),
                on: app.eventLoopGroup.any()
            )
            req.headers.contentType = .json
            #expect(req.isFormSubmission == false)
        }
    }

    @Test("isFormSubmission returns false when no content type")
    func formSubmissionWithNoContentType() async throws {
        try await withApp { app in
            let req = Request(
                application: app,
                method: .GET,
                url: .init(string: "/test"),
                on: app.eventLoopGroup.any()
            )
            #expect(req.isFormSubmission == false)
        }
    }

    // MARK: - isWaitingForHTML Tests

    @Test("isWaitingForHTML returns true for text/html accept header")
    func waitingForHTMLWithTextHTML() async throws {
        try await withApp { app in
            let req = Request(
                application: app,
                method: .GET,
                url: .init(string: "/test"),
                on: app.eventLoopGroup.any()
            )
            req.headers.add(name: .accept, value: "text/html")
            #expect(req.isWaitingForHTML == true)
        }
    }

    @Test("isWaitingForHTML returns true for text/html with charset")
    func waitingForHTMLWithCharset() async throws {
        try await withApp { app in
            let req = Request(
                application: app,
                method: .GET,
                url: .init(string: "/test"),
                on: app.eventLoopGroup.any()
            )
            req.headers.add(name: .accept, value: "text/html; charset=utf-8")
            #expect(req.isWaitingForHTML == true)
        }
    }

    @Test("isWaitingForHTML returns true for text/html in complex accept header")
    func waitingForHTMLInComplexAccept() async throws {
        try await withApp { app in
            let req = Request(
                application: app,
                method: .GET,
                url: .init(string: "/test"),
                on: app.eventLoopGroup.any()
            )
            req.headers.add(name: .accept, value: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
            #expect(req.isWaitingForHTML == true)
        }
    }

    @Test("isWaitingForHTML returns false for application/json accept header")
    func waitingForHTMLWithJSON() async throws {
        try await withApp { app in
            let req = Request(
                application: app,
                method: .GET,
                url: .init(string: "/test"),
                on: app.eventLoopGroup.any()
            )
            req.headers.add(name: .accept, value: "application/json")
            #expect(req.isWaitingForHTML == false)
        }
    }

    @Test("isWaitingForHTML returns false when no accept header")
    func waitingForHTMLWithNoAccept() async throws {
        try await withApp { app in
            let req = Request(
                application: app,
                method: .GET,
                url: .init(string: "/test"),
                on: app.eventLoopGroup.any()
            )
            #expect(req.isWaitingForHTML == false)
        }
    }

    // MARK: - Helper

    @Sendable private func withApp(
        _ closure: @Sendable (Application) async throws -> Void
    ) async throws {
        let app = try await Application.make(.testing)
        defer { Task { try? await app.asyncShutdown() } }
        try await closure(app)
    }
}
