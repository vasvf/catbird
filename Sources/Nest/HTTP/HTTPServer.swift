public protocol Server {
    func start(_ address: SocketAddress) throws
}

public class HTTPServer: Server {

    /// HTTP server configuration.
    public struct Configuration {

        /// Server logger.
        public var logger: Logger

        /// Event loop group associated with `ServerBootstrap`.
        public let group: EventLoopGroup

        /// Server channel builder.
        public var bootstrap: ServerBootstrap

        public init(logger: Logger, group: EventLoopGroup) {
            self.bootstrap = ServerBootstrap(group: group)
            self.logger = logger
            self.group = group
        }
    }

    public let configuration: Configuration

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: - Server

    public func start(_ address: SocketAddress) throws {
        defer {
            try! configuration.group.syncShutdownGracefully()
        }

        let channel = try configuration.bootstrap.bind(to: address).wait()

        guard let localAddress = channel.localAddress else {
            fatalError("Address was unable to bind. Please check that the socket was not closed or that the address family was understood.")
        }
        configuration.logger.info("Server started and listening on \(localAddress)")

        // This will never unblock as we don't close the ServerChannel
        try channel.closeFuture.wait()

        configuration.logger.info("Server closed")
    }
}

extension HTTPServer.Configuration {

    /// HTTP/1 server configuration.
    public static func http1(
        logger: Logger = Logger(label: "com.redmadrobot.nest"),
        group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount),
        handler: @escaping HTTPRequestHandler
    ) -> HTTPServer.Configuration {
        var configuration = HTTPServer.Configuration(logger: logger, group: group)

        configuration.bootstrap = configuration.bootstrap
            // Specify backlog and enable SO_REUSEADDR for the server itself
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer({ channel in
                channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).flatMap {
                    channel.pipeline.addHandler(HTTPChannelHandler(requestHandler: handler))
                }
            })
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

        return configuration
    }
}
