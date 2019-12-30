public final class ErrorMiddleware: Middleware {
    public init() {}


    // MARK: - Middleware

    public func response(_ request: HTTPRequest, next: Route) throws -> EventLoopFuture<HTTPResponse> {
        return request.eventLoop
            .makeFutureThrowing { try next.response(request) }
            .flatMapErrorThrowing { (error: Error) -> HTTPResponse in
                guard let http = error as? HTTPError else {
                    return request.response(.internalServerError, body: { $0.writeString("\(error)") })
                }
                let message = http.message ?? http.status.reasonPhrase
                return request.response(http.status, headers: http.headers, body: {
                    $0.writeString(message)
                })
            }
    }
    
}
