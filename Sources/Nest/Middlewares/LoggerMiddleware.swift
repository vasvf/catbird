public final class LoggerMiddleware: Middleware, CustomStringConvertible {

    private let logger: Logger

    public init(logger: Logger) {
        self.logger = logger
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        return "Nest.LoggerMiddleware(logger: \(logger.label))"
    }

    // MARK: - Middleware

    public func response(_ request: HTTPRequest, next: Route) throws -> EventLoopFuture<HTTPResponse> {
        let meta = "\(request.head.method.rawValue) \(request.head.uri)"
        return request.eventLoop
            .makeFutureThrowing { try next.response(request) }
            .always { [logger] (result: Result<HTTPResponse, Error>) in
                switch result {
                case .success(let response):
                    logger.info("\(meta) \(response.head.status)")
                case .failure(let error):
                    logger.error("\(meta) \(error)")
                }
            }
    }

}
