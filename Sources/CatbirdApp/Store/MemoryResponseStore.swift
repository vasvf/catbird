import CatbirdAPI
import Foundation
import Nest

final class MemoryResponseStore: HTTPResponseStore, InterseptStore {

    private var intercepts: [Intercept] = []
    private let queue = DispatchQueue(label: "MemoryResponseStore.queue")

    // MARK: - InterseptStore

    func intercepts(on eventLoop: EventLoop) -> EventLoopFuture<[Intercept]> {
        let promise = eventLoop.makePromise(of: [Intercept].self)
        queue.async {
            promise.succeed(self.intercepts)
        }
        return promise.futureResult
    }

    // MARK: - HTTPResponseStore

    func response(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        let promise = request.eventLoop.makePromise(of: HTTPResponse.self)
        queue.async {
            if let intercept = self.intercepts.first(where: { $0.match(request.head) }) {
                promise.succeed(intercept.response)
            } else {
                promise.fail(HTTPError(.notFound))
            }
        }
        return promise.futureResult
    }

    func updateResponse(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        let promise = request.eventLoop.makePromise(of: HTTPResponse.self)
        do {
            let (response, pattern) = try decode(request)
            queue.async {
                self.setResponse(response, for: pattern)
                promise.succeed(response ?? request.response(.noContent))
            }
        } catch {
            promise.fail(error)
        }
        return promise.futureResult
    }

    func removeAllResponses(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        let promise = request.eventLoop.makePromise(of: HTTPResponse.self)
        let response = request.response(.noContent)
        queue.async {
            self.intercepts.removeAll(keepingCapacity: true)
            promise.succeed(response)
        }
        return promise.futureResult
    }

    // MARK: - Private

    private func decode(_ request: HTTPRequest) throws -> (response: HTTPResponse?, pattern: RequestPattern) {
        guard let buffer = request.body else {
            throw HTTPError(.badRequest, message: "Empty body")
        }
        let decoder = JSONDecoder()
        let bag = try decoder.decode(RequestBag.self, from: buffer)
        let response = bag.data.map { (data: ResponseData) -> HTTPResponse in
            let buffer: IOData? = data.body.map { body in
                var buffer = request.allocator.buffer(capacity: body.count)
                buffer.writeBytes(body)
                return IOData.byteBuffer(buffer)
            }
            return HTTPResponse(
                version: request.head.version,
                status: HTTPResponseStatus(statusCode: data.statusCode),
                headers: HTTPHeaders(data.headerFields.map { $0 }),
                body: buffer)
        }
        return (response, bag.pattern)
    }

    private func setResponse(_ response: HTTPResponse?, for pattern: RequestPattern) {
        switch (response, intercepts.firstIndex(where: { $0.pattern == pattern })) {
        case (let response?, let index?):
            intercepts[index] = Intercept(pattern: pattern, response: response)
        case (let response?, .none):
            intercepts.append(Intercept(pattern: pattern, response: response))
        case (.none, let index?):
            intercepts.remove(at: index)
        case (.none, .none):
            break
        }
    }

}
