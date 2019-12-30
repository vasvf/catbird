/// HTTP response.
public struct HTTPResponse {

    /// Meta info.
    public var head: HTTPResponseHead

    /// HTTP response body.
    public var body: IOData?

    /// A new HTTP response.
    public init(
        head: HTTPResponseHead,
        body: IOData? = nil
    ) {
        self.head = head
        self.body = body
    }

    /// A new HTTP response.
    public init(
        version: HTTPVersion,
        status: HTTPResponseStatus,
        headers: HTTPHeaders = [:],
        body: IOData? = nil
    ) {
        self.head = HTTPResponseHead(
            version: version,
            status: status,
            headers: headers
        )
        self.body = body
    }

    /// The number of body bytes.
    public var count: Int {
        switch body {
        case .none:
            return 0
        case .byteBuffer(let buffer)?:
            return buffer.readableBytes
        case .fileRegion(let fileRegion)?:
            return fileRegion.endIndex
        }
    }

    /// Add missing headers.
    mutating func normalize() {
        if body != nil, !head.headers.contains(name: "Content-Length") {
            head.headers.add(name: "Content-Length", value: "\(count)")
        }
//        response.headers.add(name: "Content-Type", value: "text/plain; charset=utf-8")
    }
}
