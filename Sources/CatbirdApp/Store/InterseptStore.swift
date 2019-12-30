import CatbirdAPI
import Nest

/// HTTP request intercept store.
protocol InterseptStore {

    /// Fetch all stored intercepts.
    func intercepts(on eventLoop: EventLoop) -> EventLoopFuture<[Intercept]>
}

protocol HTTPResponseStore2 {
    func response(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse>
}

/// HTTP request intercept store.
protocol InterseptStore2 {

    /// Fetch all stored intercepts.
    func intercepts(on eventLoop: EventLoop) -> EventLoopFuture<[Intercept]>
    func setIntercept(intercept: Intercept, on eventLoop: EventLoop) -> EventLoopFuture<Void>
    func removeIntercept(for pattern: RequestPattern, on eventLoop: EventLoop) -> EventLoopFuture<Void>
    func removeAllIntercepts(on eventLoop: EventLoop) -> EventLoopFuture<Void>
}
