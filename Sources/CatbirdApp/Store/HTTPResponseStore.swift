import CatbirdAPI
import Nest

/// Any content store that can be submitted as an HTTP response and retrieved on HTTP request.
protocol HTTPResponseStore {

    /// Fetch response for request.
    ///
    /// - Remark: Used in Middleware.
    func response(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse>

    /// Add, update or remove response for request.
    ///
    /// - Remark: Used in Middleware and API.
    func updateResponse(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse>

    /// Remove all responses.
    ///
    /// - Remark: Used in API.
    func removeAllResponses(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse>
}

protocol HTTPResponseReader {

    /// Fetch response for request.
    ///
    /// - Remark: Used in Middleware.
    func response(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse>
}

/// Response update command.
enum ResponseUpdate {
    case setResponse(HTTPRequest, HTTPResponse)
    case setIntersept(Intercept)
    case removePattern(RequestPattern)
}

protocol HTTPResponseWriter {

    /// Add, update or remove response for request.
    ///
    /// - Remark: Used in Middleware and API.
    func setResponse(_ response: HTTPResponse, for request: HTTPRequest) -> EventLoopFuture<HTTPResponse>

    /// Remove all responses.
    ///
    /// - Remark: Used in API.
    func removeAllResponses(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse>
}

