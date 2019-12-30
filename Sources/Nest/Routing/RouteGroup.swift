public protocol RouteGroup: Route {
    var path: String { get }
    var routes: [Route] { get set }
}

extension RouteGroup {
    public mutating func route(_ method: HTTPMethod, _ path: String = "", use handler: @escaping HTTPRequestHandler) {
        let route = BaseRoute(method: method, path: self.path + path, handler: handler)
        routes.append(route)
    }

    public mutating func get(_ path: String = "", use handler: @escaping HTTPRequestHandler) {
        route(.GET, path, use: handler)
    }

    public mutating func post(_ path: String = "", use handler: @escaping HTTPRequestHandler) {
        route(.POST, path, use: handler)
    }

    public mutating func put(_ path: String = "", use handler: @escaping HTTPRequestHandler) {
        route(.PUT, path, use: handler)
    }

    public mutating func patch(_ path: String = "", use handler: @escaping HTTPRequestHandler) {
        route(.PATCH, path, use: handler)
    }

    public mutating func delete(_ path: String = "", use handler: @escaping HTTPRequestHandler) {
        route(.DELETE, path, use: handler)
    }
}

