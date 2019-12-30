import AsyncHTTPClient
import CatbirdAPI
import Foundation
import Nest

final class FileResponseStore: HTTPResponseStore, CustomStringConvertible {

    /// The directory for response files.
    private let directory: URL

    private let fileIO: NonBlockingFileIO
    private let httpClient: HTTPClient

    init(directory: URL, fileIO: NonBlockingFileIO, httpClient: HTTPClient) {
        self.directory = directory
        self.fileIO = fileIO
        self.httpClient = httpClient
    }

    var description: String {
        return "FileResponseStore(directory: \(directory)"
    }

    // MARK: - HTTPResponseStore

    func response(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        let eventLoop = request.eventLoop

        guard let url = URL(string: directory.absoluteString + request.head.uri) else {
            let error = URLError(.badURL, userInfo: [NSFilePathErrorKey: request.head.uri])
            return eventLoop.makeFailedFuture(error)
        }

        return open(at: url, on: eventLoop).map { request.response(body: .fileRegion($0)) }
    }

    func updateResponse(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        let eventLoop = request.eventLoop

        fatalError()

//        return httpClient.execute(request).flatMap { (response: HTTPResponse) -> EventLoopFuture<HTTPResponse> in
//            let filePath = self.folder + request.head.uri

//            return self.fileIO
//                .openFile(path: filePath, mode: .write, flags: .allowFileCreation(), eventLoop: eventLoop)
//                .flatMap { (fileHandle: NIOFileHandle) -> EventLoopFuture<Void> in
//                    return fileIO
//                        .write(fileHandle: fileHandle, buffer: response.body, eventLoop: eventLoop)
//                        .flatMapThrowing { try fileHandle.close() }
//                }
//                .map { response }
//        }
    }

    func removeAllResponses(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        return request.eventLoop.makeFailedFuture(HTTPError(.forbidden))
    }

    // MARK: - Private

    private func open(at url: URL, on eventLoop: EventLoop) -> EventLoopFuture<FileRegion> {
        return fileIO.openFile(path: url.absoluteString, eventLoop: eventLoop).map { $0.1 }
    }

    public func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            return eventLoop.makeSucceededFuture(())
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }

    private func write(_ response: HTTPResponse, at path: String, for request: HTTPRequest) -> EventLoopFuture<Void> {
        let eventLoop = request.eventLoop

        guard let url = URL(string: request.head.uri) else {
            let url = URLError(.badURL, userInfo: [NSFilePathErrorKey: request.head.uri])
            return eventLoop.makeFailedFuture(url)
        }



        fatalError()

        //FileManager.default.createDirectory(at: <#T##URL#>, withIntermediateDirectories: <#T##Bool#>, attributes: <#T##[FileAttributeKey : Any]?#>)
    }

//    func response(for request: HTTPRequest) throws -> HTTPResponse {
//        let url = URL(fileURLWithPath: path + request.head.uri, isDirectory: false)
//        let data = try Data(contentsOf: url)
//        fatalError()
////        return request.response(.ok, body: nil)
//    }
//
//    func setResponse(data: ResponseData?, for pattern: RequestPattern) throws {
//        guard let body = data?.body else { return }
//
//        let patternPath: String
//        if case .equal = pattern.url.kind, let url = URL(string: pattern.url.value) {
//            patternPath = url.path
//        } else {
//            patternPath = pattern.url.value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
//        }
//        let url = URL(fileURLWithPath: path + patternPath, isDirectory: false)
//
//        try fileManager.createDirectory(
//            at: url.deletingLastPathComponent(), // Remove file name
//            withIntermediateDirectories: true
//        )
//        try body.write(to: url)
//    }

}

final class FileInterceptStore: InterseptStore2 {

    /// The directory for response files.
    private let directory: URL

    /// Async file manager.
    private let fileIO: NonBlockingFileIO

    init(directory: URL, fileIO: NonBlockingFileIO) {
        self.directory = directory
        self.fileIO = fileIO
    }

    // MARK: - InterseptStore2

    func intercepts(on eventLoop: EventLoop) -> EventLoopFuture<[Intercept]> {
        return eventLoop.makeFailedFuture(HTTPError(.notImplemented))
    }

    func setIntercept(intercept: Intercept, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        fatalError()
    }

    func removeIntercept(for pattern: RequestPattern, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        return eventLoop.makeFailedFuture(HTTPError(.forbidden))

    }

    func removeAllIntercepts(on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        return eventLoop.makeFailedFuture(HTTPError(.forbidden))
    }

}

// MARK: - CustomStringConvertible

extension FileInterceptStore: CustomStringConvertible {
    var description: String {
        return "FileInterceptStore(directory: \(directory)"
    }
}
