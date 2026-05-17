import Foundation

/// The result of a successful `perform(target:response:)` call.
///
/// Carries the decoded body alongside the raw `URLResponse` and the
/// `URLRequest` that was actually sent (post-adapter chain) — useful
/// for inspecting status codes, response headers, or echoing the
/// request in logs.
public struct NetworkResponse<R: Decodable> {
    /// The decoded response body.
    public let response: R

    /// The raw `URLResponse`. Cast to `HTTPURLResponse` to inspect
    /// status code and headers.
    public let urlResponse: URLResponse

    /// The request that was actually sent (after all adapters ran).
    public let originalRequest: URLRequest
}
