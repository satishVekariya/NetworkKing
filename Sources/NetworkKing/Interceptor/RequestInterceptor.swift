import Foundation

/// Composes multiple `RequestAdapter`s and `RequestRetrier`s into a single value
/// that `NetworkProvider` consumes.
///
/// Behavior:
/// - **Adapters** run in the order supplied. Each receives the request as
///   produced by the previous adapter. A later adapter overrides an earlier
///   one's headers / body changes.
/// - **Retriers** are consulted in order, stopping at the first one that
///   returns `.retry`. An earlier `.doNotRetry` therefore does **not** veto
///   a later retrier's `.retry`.
///
/// ## Example
///
/// ```swift
/// let interceptor = RequestInterceptor(
///     adapters: [LoggingAdapter(), AuthAdapter(token: { Keychain.token })],
///     retriers: [UnauthorizedRetrier(refreshToken: refresh)]
/// )
/// let provider = NetworkProvider<UserAPI>(requestInterceptor: interceptor)
/// ```
public struct RequestInterceptor: RequestAdapter, RequestRetrier {
    /// Adapters applied to every outgoing request, in order.
    public let adapters: [RequestAdapter]

    /// Retriers consulted when a request fails, in order.
    public let retriers: [RequestRetrier]

    public init(adapters: [RequestAdapter] = [], retriers: [RequestRetrier] = []) {
        self.adapters = adapters
        self.retriers = retriers
    }

    /// Pipe the request through every adapter sequentially.
    public func adapt(_ urlRequest: URLRequest, for target: NetworkTargetType) async throws -> URLRequest {
        var urlRequest = urlRequest
        for adapter in adapters {
            urlRequest = try await adapter.adapt(urlRequest, for: target)
        }
        return urlRequest
    }

    /// Walk the retrier chain; stop at the first `.retry`.
    public func retry(_ request: URLRequest, for target: NetworkTargetType, dueTo error: Error) async throws -> RetryResult {
        var finalResult = RetryResult.doNotRetry

        for retrier in retriers {
            finalResult = try await retrier.retry(request, for: target, dueTo: error)
            if finalResult == .retry {
                break
            }
        }
        return finalResult
    }
}
