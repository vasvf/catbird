public protocol Route {
    func match(_ request: HTTPRequest) -> Bool
    func response(_ request: HTTPRequest) throws -> EventLoopFuture<HTTPResponse>
}
