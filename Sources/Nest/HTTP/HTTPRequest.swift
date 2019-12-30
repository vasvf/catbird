/// Any HTTP request handler.
public typealias HTTPRequestHandler = (HTTPRequest) throws -> EventLoopFuture<HTTPResponse>

/// HTTP request execution context.
///
/// - Remark: Contains all dependencies of `HTTPRequest`.
public protocol HTTPRequestContext {

    /// HTTP request `EventLoop`.
    var eventLoop: EventLoop { get }

    /// Response body memory allocator.
    var allocator: ByteBufferAllocator { get }
}

/// HTTP request.
public final class HTTPRequest {

    /// Method, URI and headers.
    public var head: HTTPRequestHead

    /// Request body.
    public let body: ByteBuffer?

    /// Request execution context.
    public let context: HTTPRequestContext

    /// A new HTTP request.
    ///
    /// - Parameters:
    ///   - head: Method, URI and headers.
    ///   - body: Request body.
    ///   - context: Request execution context.
    public init(
        head: HTTPRequestHead,
        body: ByteBuffer?,
        context: HTTPRequestContext
    ) {
        self.head = head
        self.body = body
        self.context = context
    }

}

// MARK: - HTTPRequest + HTTPRequestContext

/// Convenient access to `HTTPRequest` dependencies.
extension HTTPRequest: HTTPRequestContext {

    /// HTTP request `EventLoop`.
    public var eventLoop: EventLoop { return context.eventLoop }

    /// Response body memory allocator.
    public var allocator: ByteBufferAllocator { return context.allocator }

}

// MARK: - HTTPRequest + HTTPResponse

/// `HTTPResponse` factory methods.
extension HTTPRequest {

    /// Cretate a new HTTP response.
    ///
    /// - Parameters:
    ///   - status: A HTTP response status code. Default 200 OK.
    ///   - headers: HTTP header fields. Default empty.
    ///   - body: Function to write HTTP response body. Default `nil`.
    /// - Returns: A new HTTP response.
    public func response(
        _ status: HTTPResponseStatus = .ok,
        headers: HTTPHeaders = [:],
        body write: (inout ByteBuffer) -> Void
    ) -> HTTPResponse {

        var buffer = allocator.buffer(capacity: 0)
        write(&buffer)
        return response(status, headers: headers, body: .byteBuffer(buffer))
    }

    /// Cretate a new HTTP response with file or empty.
    ///
    /// - Parameters:
    ///   - status: A HTTP response status code. Default 200 OK.
    ///   - headers: HTTP header fields. Default empty.
    ///   - body: Any data. Default `nil`.
    /// - Returns: A new HTTP response.
    public func response(
        _ status: HTTPResponseStatus = .ok,
        headers: HTTPHeaders = [:],
        body: IOData? = nil
    ) -> HTTPResponse {

        let head = HTTPResponseHead(
            version: self.head.version,
            status: status,
            headers: headers
        )
        var response = HTTPResponse(head: head, body: body)
        response.normalize()
        return response
    }

}
