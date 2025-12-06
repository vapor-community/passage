import Testing
import Vapor
import NIOCore

extension Tag {
    @Tag static var unit: Self
    @Tag static var security: Self
    @Tag static var integration: Self
}

extension Tag {
    @Tag static var login: Self
    @Tag static var register: Self
    @Tag static var verifyEmail: Self
    @Tag static var verifyPhone: Self
    @Tag static var resetPassword: Self
    @Tag static var federatedLogin: Self
}

// MARK: - Mock ViewRenderer for Testing

/// Mock ViewRenderer for testing that captures template names and context data
/// without requiring Leaf template rendering
final class CapturingViewRenderer: ViewRenderer, @unchecked Sendable {
    var shouldCache = false
    var eventLoop: EventLoop

    private(set) var capturedContext: Encodable?
    private(set) var templatePath: String?

    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }

    func `for`(_ request: Request) -> ViewRenderer {
        return self
    }

    func render<E>(_ name: String, _ context: E) -> EventLoopFuture<View> where E: Encodable {
        self.capturedContext = context
        self.templatePath = name

        // Return a dummy view with the template name
        var byteBuffer = ByteBufferAllocator().buffer(capacity: name.count)
        byteBuffer.writeString("Rendered: \(name)")
        let view = View(data: byteBuffer)
        return eventLoop.future(view)
    }
}
