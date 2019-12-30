extension ChannelHandlerContext: HTTPRequestContext {
    public var allocator: ByteBufferAllocator { return channel.allocator }
}

public final class HTTPChannelHandler: ChannelInboundHandler {

    /// HTTP request handler.
    private let requestHandler: HTTPRequestHandler

    /// Incoming HTTP request head.
    private var requestHead: HTTPRequestHead?
    /// Incoming HTTP request body.
    private var requestBody: ByteBuffer?

    public init(requestHandler: @escaping HTTPRequestHandler) {
        self.requestHandler = requestHandler
    }

    // MARK: - ChannelInboundHandler

    public typealias InboundIn = HTTPServerRequestPart
    public typealias OutboundOut = HTTPServerResponsePart

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        switch unwrapInboundIn(data) {
        case .head(let head):
            requestHead = head
            requestBody = context.channel.allocator.buffer(capacity: 0)
        case .body(var body):
            assert(requestHead != nil)
            requestBody?.writeBuffer(&body)
        case .end(let headers):
            assert(headers == nil)
            let request = HTTPRequest(head: requestHead!, body: requestBody, context: context)
            let future = context.eventLoop.makeFutureThrowing { try self.requestHandler(request) }
            future.whenFailure { context.fireErrorCaught($0) }
            future.whenSuccess { self.sendResponse($0, context: context) }
        }
    }

    // MARK: - Private

    private func sendResponse(_ response: HTTPResponse, context: ChannelHandlerContext) {
        switch response.body {
        case .none:
            sendHead(response.head, context: context)
        case .byteBuffer(let byteBuffer)?:
            sendBuffer(byteBuffer, head: response.head, context: context)
        case .fileRegion(let fileRegion)?:
            sendFileRegion(fileRegion, head: response.head, context: context)
        }
    }

    private func sendHead(_ head: HTTPResponseHead, context: ChannelHandlerContext) {
        context.write(wrapOutboundOut(.head(head)), promise: nil)
        context.writeAndFlush(wrapOutboundOut(.end(nil)), promise: nil)
    }

    private func sendBuffer(_ buffer: ByteBuffer, head: HTTPResponseHead, context: ChannelHandlerContext) {
        context.write(wrapOutboundOut(.head(head)), promise: nil)
        context.write(wrapOutboundOut(.body(IOData.byteBuffer(buffer))), promise: nil)
        context.writeAndFlush(wrapOutboundOut(.end(nil)), promise: nil)
    }

    private func sendFileRegion(_ fileRegion: FileRegion, head: HTTPResponseHead, context: ChannelHandlerContext) {
        context.write(self.wrapOutboundOut(.head(head)), promise: nil)
        context.writeAndFlush(self.wrapOutboundOut(.body(.fileRegion(fileRegion))))
            .flatMap { context.writeAndFlush(self.wrapOutboundOut(.end(nil))) }
            .whenComplete { _ in try! fileRegion.fileHandle.close() }
    }

}
