public protocol Server {
    func start(_ address: SocketAddress) throws
}

extension Server {
    public func start(port: Int) throws {
        let address = try SocketAddress.makeAddressResolvingHost("::1", port: 8080)
        try self.start(address)
    }
}
