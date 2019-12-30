struct BaseRoute: Route, CustomStringConvertible {
    let method: HTTPMethod
    let path: String
    let handler: HTTPRequestHandler

    // MARK: - CustomStringConvertible

    var description: String {
        return "\(method.rawValue) \(path)"
    }

    // MARK: - Route

    func match(_ request: HTTPRequest) -> Bool {
        request.head.method == method && request.head.uri == path
    }

    func response(_ request: HTTPRequest) throws -> EventLoopFuture<HTTPResponse> {
        return try handler(request)
    }

}
