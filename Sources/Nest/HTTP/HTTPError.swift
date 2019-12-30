public struct HTTPError: Error {
    public var status: HTTPResponseStatus
    public var headers: HTTPHeaders
    public let message: String?

    public init(
        _ status: HTTPResponseStatus,
        headers: HTTPHeaders = [:],
        message: String? = nil
    ) {
        self.status = status
        self.headers = headers
        self.message = message
    }
    
}
