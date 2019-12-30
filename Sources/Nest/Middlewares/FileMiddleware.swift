import Foundation

// https://github.com/apple/swift-nio/blob/master/Sources/NIOHTTP1Server/main.swift
// https://github.com/vapor/vapor/blob/master/Sources/Vapor/Middleware/FileMiddleware.swift
public final class FileMiddleware: Middleware, CustomStringConvertible {
    public let directory: URL
    public let fileIO: NonBlockingFileIO

    public init(directory: URL, fileIO: NonBlockingFileIO) {
        self.directory = directory
        self.fileIO = fileIO
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        return "Nest.FileMiddleware(directory: \(directory))"
    }

    // MARK: - Middleware

    public func response(_ request: HTTPRequest, next route: Route) throws -> EventLoopFuture<HTTPResponse> {
        let path = request.head.uri

        guard !request.head.uri.contains("../") else {
            throw HTTPError(.forbidden)
        }

        guard request.head.method == .GET else {
            return try route.response(request)
        }

        let filePath = directory.absoluteString + path

        guard fileExists(at: filePath) else {
            return try route.response(request)
        }

        return fileIO
            .openFile(path: filePath, eventLoop: request.eventLoop)
            .map { (_: NIOFileHandle, fileRegion: FileRegion) -> HTTPResponse in
                return request.response(body: .fileRegion(fileRegion))
            }
    }

    // MARK: - Private

    private func fileExists(at path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && !isDirectory.boolValue
    }

}
