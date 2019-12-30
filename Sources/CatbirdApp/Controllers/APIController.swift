import CatbirdAPI
import Foundation
import Nest

final class InterceptAPIController {

    private let store: InterseptStore2

    init(store: InterseptStore2) {
        self.store = store
    }

    func upate(_ request: HTTPRequest) throws -> EventLoopFuture<HTTPResponse> {
        guard let buffer = request.body else {
            throw HTTPError(.badRequest, message: "Empty body")
        }
        let decoder = JSONDecoder()
        let bag = try decoder.decode(RequestBag.self, from: buffer)

        guard let data = bag.data else {
            return store
                .removeIntercept(for: bag.pattern, on: request.eventLoop)
                .map { request.response(.noContent) }
        }

        let body: IOData? = data.body.map { body in
            var buffer = request.allocator.buffer(capacity: body.count)
            buffer.writeBytes(body)
            return IOData.byteBuffer(buffer)
        }
        let response = HTTPResponse(
            version: request.head.version,
            status: HTTPResponseStatus(statusCode: data.statusCode),
            headers: HTTPHeaders(data.headerFields.map { $0 }),
            body: body
        )
        let intercept = Intercept(pattern: bag.pattern, response: response)
        return store
            .setIntercept(intercept: intercept, on: request.eventLoop)
            .map { response }
    }

    func clear(_ request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        return store
            .removeAllIntercepts(on: request.eventLoop)
            .map { request.response(.noContent) }
    }

}
