// Exported dependecies
@_exported import NIO
@_exported import NIOHTTP1
@_exported import NIOFoundationCompat
@_exported import Logging
@_exported import AsyncHTTPClient

extension EventLoop {

    public func makeFutureThrowing<T>(
        _ task: () throws -> EventLoopFuture<T>
    ) -> EventLoopFuture<T> {
        do {
            self.assertInEventLoop()
            let future = try task()
            assert(self === future.eventLoop)
            return future
        } catch {
            return self.makeFailedFuture(error)
        }
    }

}
