import Foundation
import Nest

final class InterseptStoreMiddleware: Middleware {

    private let store: InterseptStore2

    init(store: InterseptStore2) {
        self.store = store
    }

    // MARK: - Middleware

    func response(_ request: HTTPRequest, next route: Route) throws -> EventLoopFuture<HTTPResponse> {
        return request.eventLoop
            .makeFutureThrowing { try route.response(request) }
            .flatMap { [store] (response: HTTPResponse) -> EventLoopFuture<HTTPResponse> in
                let intercept = Intercept(request: request, response: response)
                return store
                    .setIntercept(intercept: intercept, on: request.eventLoop)
                    .map { response }
            }
    }

}
