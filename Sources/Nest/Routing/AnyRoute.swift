struct AnyRoute: Route {
    let handler: HTTPRequestHandler

    // MARK: - Route

    func match(_ request: HTTPRequest) -> Bool {
        return true
    }

    func response(_ request: HTTPRequest) throws -> EventLoopFuture<HTTPResponse> {
        return try handler(request)
    }
}
