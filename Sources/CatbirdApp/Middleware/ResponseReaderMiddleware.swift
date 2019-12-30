import Nest

final class ResponseReaderMiddleware: Middleware {

    private let store: HTTPResponseStore

    init(store: HTTPResponseStore) {
        self.store = store
    }

    // MARK: - Middleware

    func response(_ request: HTTPRequest, next route: Route) throws -> EventLoopFuture<HTTPResponse> {
        return request.eventLoop
            .makeFutureThrowing { try route.response(request) }
            .flatMapError { [store] (error: Error) -> EventLoopFuture<HTTPResponse> in
                guard (error as? HTTPError)?.status == .notFound else {
                    return request.eventLoop.makeFailedFuture(error)
                }
                return store.response(for: request)
            }
    }

}

final class ResponseStoreMiddleware: Middleware, CustomStringConvertible {

    private let store: HTTPResponseStore2

    init(store: HTTPResponseStore2) {
        self.store = store
    }

    // MARK: - CustomStringConvertible

    var description: String {
        return "Catbird.ResponseStoreMiddleware(store: \(store)"
    }

    // MARK: - Middleware

    func response(_ request: HTTPRequest, next route: Route) throws -> EventLoopFuture<HTTPResponse> {
        return request.eventLoop
            .makeFutureThrowing { try route.response(request) }
            .flatMapError { [store] (error: Error) -> EventLoopFuture<HTTPResponse> in
                guard (error as? HTTPError)?.status == .notFound else {
                    return request.eventLoop.makeFailedFuture(error)
                }
                return store.response(for: request)
            }
    }

}

