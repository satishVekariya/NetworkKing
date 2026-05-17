import Foundation

/// Anything that can produce a `URLRequest`.
///
/// `NetworkTargetType` refines this protocol — most consumers should
/// conform to `NetworkTargetType` rather than this directly.
public protocol URLRequestConvertible {
    /// Build the `URLRequest` represented by this value.
    /// - Throws: Any error encountered while constructing the request
    ///           (e.g., body encoding failure).
    func toURLRequest() throws -> URLRequest
}

public extension URLRequestConvertible {
    /// Non-throwing convenience: returns the request, or `nil` if
    /// `toURLRequest()` would throw. Useful for logging / diagnostics
    /// where the actual error is not actionable.
    var urlRequest: URLRequest? {
        try? toURLRequest()
    }
}
