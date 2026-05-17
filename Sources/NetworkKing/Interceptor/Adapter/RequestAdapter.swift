import Foundation

/// Inspects or rewrites a `URLRequest` before it leaves the provider.
///
/// Typical uses: attaching auth tokens, logging, signing, injecting
/// telemetry headers. Adapters are run **on every attempt**, including
/// retries — so a token-refresh retrier can simply trigger `.retry` and
/// let the auth adapter pick up the new token on the next pass.
///
/// ## Example
///
/// ```swift
/// struct AuthAdapter: RequestAdapter {
///     let token: @Sendable () -> String?
///     func adapt(_ urlRequest: URLRequest, for target: NetworkTargetType) async throws -> URLRequest {
///         var request = urlRequest
///         if let t = token() {
///             request.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
///         }
///         return request
///     }
/// }
/// ```
public protocol RequestAdapter: Sendable {
    /// Return an adapted copy of `urlRequest` (or the same value if no change is needed).
    /// Throws to fail the request before it is sent.
    func adapt(_ urlRequest: URLRequest, for target: NetworkTargetType) async throws -> URLRequest
}
