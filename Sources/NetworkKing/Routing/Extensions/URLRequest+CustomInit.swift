import Foundation

public extension URLRequest {
    /// Convenience initializer that assigns method and headers in one call.
    ///
    /// - Parameters:
    ///   - url:     The destination URL.
    ///   - method:  The HTTP verb. Written to `httpMethod` as its raw value.
    ///   - headers: Optional headers. When `nil`, no headers are set.
    /// - Throws:    Reserved for future use; currently does not throw.
    init(url: URL, method: HTTPMethod, headers: HTTPHeaders? = nil) throws {
        self.init(url: url)
        httpMethod = method.rawValue
        allHTTPHeaderFields = headers
    }
}
