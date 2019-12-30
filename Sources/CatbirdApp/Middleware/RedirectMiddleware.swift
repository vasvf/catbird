import AsyncHTTPClient
import Foundation
import Nest

final class RedirectMiddleware: Middleware, CustomStringConvertible {

    /// Redirect URL.
    private let url: URL

    /// Async HTTP client.
    private let httpClient: HTTPClient

    /// Create e new redirect middleware.
    ///
    /// - Parameters:
    ///   - url: Redirect URL.
    ///   - httpClient: Async HTTP client.
    init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }

    // MARK: - CustomStringConvertible

    var description: String {
        return "Catbird.RedirectMiddleware(url: \(url)"
    }

    // MARK: - Middleware

    func response(_ request: HTTPRequest, next route: Route) throws -> EventLoopFuture<HTTPResponse> {
        // Redirect to another server
        request.head.uri = url.absoluteString + request.head.uri

        return request.eventLoop.makeFutureThrowing {
            httpClient.execute(
                request: try request.makeHTTPClientRequest(),
                eventLoop: .delegate(on: request.eventLoop))
        } .map { $0.makeHTTPResponse(version: request.head.version) }
    }
}

// MARK: - Nest + AsyncHTTPClient

private extension Nest.HTTPRequest {
    /// - Throws: Invalid URL error.
    func makeHTTPClientRequest() throws -> AsyncHTTPClient.HTTPClient.Request {
        return try HTTPClient.Request(
            url: head.uri,
            method: head.method,
            headers: head.headers,
            body: body.map(HTTPClient.Body.byteBuffer))
    }
}

private extension AsyncHTTPClient.HTTPClient.Response {
    func makeHTTPResponse(version: HTTPVersion) -> Nest.HTTPResponse {
        return HTTPResponse(
            head: HTTPResponseHead(version: version, status: status, headers: headers),
            body: body.map(IOData.byteBuffer))
    }
}
