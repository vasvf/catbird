import Foundation

/// Web application.
public final class Application: Server {

    public struct Configuration {
        public var logger: Logger
        public var group: EventLoopGroup
        public var threadPool: NIOThreadPool
        public var fileIO: NonBlockingFileIO
        public var client: HTTPClient

        public init(
            logger: Logger = Logger(label: "com.redmadrobot.nest"),
            group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount),
            threadPool: NIOThreadPool = NIOThreadPool(numberOfThreads: 1)
        ) {
            self.logger = logger
            self.group = group
            self.threadPool = threadPool
            self.fileIO = NonBlockingFileIO(threadPool: threadPool)
            self.client = HTTPClient(eventLoopGroupProvider: .shared(group))
        }
    }

    /// Application configuration.
    public let configuration: Configuration

    /// Web server.
    public let server: Server

    // MARK: - Init

    public init(configuration: Configuration = Configuration(), server: Server) {
        self.configuration = configuration
        self.server = server
    }

    public init(configuration: Configuration = Configuration(), routes: (inout Router) -> Void) {
        self.configuration = configuration
        var router = Router()
        routes(&router)
        self.server = HTTPServer(configuration: .http1(
            logger: configuration.logger,
            group: configuration.group,
            handler: router.response))
    }

    // MARK: - Server

    public func start(_ address: SocketAddress) throws {
        configuration.threadPool.start()
        defer {
            try! configuration.threadPool.syncShutdownGracefully()
            try! configuration.client.syncShutdown()
        }
        try server.start(address)
    }
}
