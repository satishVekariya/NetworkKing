import Foundation

/// Inspects a successful (`URLSession`-level) response before decoding.
///
/// The validator runs **after** the transport returns and **before**
/// JSON decoding. Returning `.failure` aborts decoding and causes
/// `NetworkProvider.perform(...)` to throw
/// `NetworkError.responseValidationFailed` — which also feeds into the
/// retry chain, so retriers can inspect the failure and trigger a retry.
///
/// ## Example: treat non-2xx as failure
///
/// ```swift
/// struct StatusCodeValidator: DataResponseValidator {
///     func validate(_ data: Data, response: URLResponse) -> Result<Void, NetworkError> {
///         guard let http = response as? HTTPURLResponse else { return .success(()) }
///         guard (200..<300).contains(http.statusCode) else {
///             return .failure(.responseValidationFailed(
///                 error: NSError(domain: "HTTP", code: http.statusCode)
///             ))
///         }
///         return .success(())
///     }
/// }
/// ```
public protocol DataResponseValidator: Sendable {
    /// Validate the response. Return `.success(())` to proceed to decoding,
    /// or `.failure(.responseValidationFailed(...))` to abort.
    func validate(_ data: Data, response urlResponse: URLResponse) -> Result<Void, NetworkError>
}
