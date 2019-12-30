import CatbirdAPI
import Nest

final class LoggedResponseStore: HTTPResponseStore {

    private let store: HTTPResponseStore
    private let logger: Logger

    init(store: HTTPResponseStore, logger: Logger) {
        self.store = store
        self.logger = logger
    }

    // MARK: - ResponseStore

    func response(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        logger.debug("read at url: \(request.head.uri)")
        return store.response(for: request)
    }

    func updateResponse(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        logger.debug("update at url: \(request.head.uri)")
        return store.updateResponse(for: request)
    }

    func removeAllResponses(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        logger.debug("remove all responses")
        return store.removeAllResponses(for: request)
    }

}
