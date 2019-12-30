/// HTTP request router.
public struct Router: RouteGroup {
    public let path: String
    public var routes: [Route] = []
    public var middlewares: [Middleware] = []

    public init(path: String = "", middlewares: [Middleware] = []) {
        self.path = path
        self.middlewares = middlewares
    }

    public mutating func group(_ path: String, boot: (inout Router) -> Void) {
        var router = Router(path: self.path + path, middlewares: [])
        boot(&router)
        routes.append(router)
    }

    // MARK: - Route

    public func match(_ request: HTTPRequest) -> Bool {
        return request.head.uri == path
    }

    public func response(_ request: HTTPRequest) throws -> EventLoopFuture<HTTPResponse> {
        let last = AnyRoute { [routes] (request: HTTPRequest) -> EventLoopFuture<HTTPResponse> in
            guard let route = routes.first(where: { $0.match(request) }) else {
                throw HTTPError(.notFound)
            }
            return try route.response(request)
        }
        let first = middlewares.reversed().reduce(last) { (route: AnyRoute, middleware: Middleware) -> AnyRoute in
            return AnyRoute { (request: HTTPRequest) throws -> EventLoopFuture<HTTPResponse> in
                return try middleware.response(request, next: route)
            }
        }
        return try first.response(request)
    }

}

// MARK: - Print

extension Router: TextOutputStreamable {
    public func write<Target>(to target: inout Target) where Target: TextOutputStream {
        var indent = Indent(stream: target)
        target.write("Router {\n")
        middlewares.forEach { print($0, to: &indent) }
        routes.forEach { print($0, to: &indent) }
        target.write("}")
    }
}

struct Indent: TextOutputStream {
    let prefix = "\t"
    var stream: TextOutputStream

    mutating func write(_ string: String) {
        if string.isEmpty || string.allSatisfy { $0.isNewline || $0.isWhitespace } {
            stream.write(string)
        } else {
            stream.write("\(prefix)\(string)")
        }
    }
}

