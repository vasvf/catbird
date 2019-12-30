import CatbirdAPI
import Nest

/// HTTP request intercept.
struct Intercept {

    /// HTTP request pattern.
    let pattern: RequestPattern

    /// HTTP response.
    let response: HTTPResponse

}

extension Intercept {

    init(request: HTTPRequest, response: HTTPResponse) {
        var headers: [String: String] = [:]
        request.head.headers.forEach { headers[$0] = $1 }

        self.pattern = RequestPattern(
            method: request.head.method.rawValue,
            url: request.head.uri,
            headerFields: headers
        )
        self.response = response
    }

//    init(pattern: RequestPattern, data: ResponseData) {
//        var headers: [String: String] = [:]
//        request.head.headers.forEach { headers[$0] = $1 }
//
//        self.pattern = RequestPattern(
//            method: request.head.method.rawValue,
//            url: request.head.uri,
//            headerFields: headers
//        )
//        self.response = response
//    }

    func match(_ head: HTTPRequestHead) -> Bool {
        return pattern.method == head.method.rawValue
            && pattern.url.match(head.uri)
            && pattern.headerFields.allSatisfy { (key: String, value: Pattern) -> Bool in
                // We not support multiple headers with the same key
                return head.headers[key].first.map(value.match) ?? false
            }
    }

}
