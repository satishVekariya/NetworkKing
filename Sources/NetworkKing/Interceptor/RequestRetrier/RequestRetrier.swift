import Foundation

/// Decides whether a failed request should be retried.
///
/// `NetworkProvider` consults retriers when an attempt throws — whether
/// the failure came from the transport layer (`URLSession`) or the
/// `DataResponseValidator`. The chain is short-circuited at the **first
/// retrier that returns `.retry`** (see `RequestInterceptor.retry`).
///
/// Only **one** retry is performed; if the retried attempt also fails,
/// the error is rethrown without consulting retriers again.
///
/// ## Example: refresh-token on 401
///
/// ```swift
/// struct UnauthorizedRetrier: RequestRetrier {
///     let refreshToken: @Sendable () async -> Bool
///     func retry(_ request: URLRequest, for target: NetworkTargetType, dueTo error: Error) async throws -> RetryResult {
///         guard case .responseValidationFailed = error as? NetworkError else {
///             return .doNotRetry
///         }
///         return await refreshToken() ? .retry : .doNotRetry
///     }
/// }
/// ```
public protocol RequestRetrier: Sendable {
    /// Decide whether the failed request should be retried.
    /// - Parameters:
    ///   - request: The request as it was sent (post-adapter chain).
    ///   - target:  The original `NetworkTargetType` value.
    ///   - error:   The error that caused the failure.
    func retry(_ request: URLRequest, for target: NetworkTargetType, dueTo error: Error) async throws -> RetryResult
}

/// Outcome of a retrier's decision.
public enum RetryResult: Sendable {
    /// Rebuild the request and try again exactly once.
    case retry

    /// Give up; propagate the original error to the caller.
    case doNotRetry
}
