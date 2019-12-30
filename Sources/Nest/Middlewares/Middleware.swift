public protocol Middleware {
    func response(_ request: HTTPRequest, next route: Route) throws -> EventLoopFuture<HTTPResponse>
}
