import Foundation

/// Alias for `URLSession`. Lets callers pass `.shared`, an ephemeral
/// session, or a mock-protocol session interchangeably.
public typealias Session = URLSession

/// Abstract contract for executing requests of a given `Target`.
///
/// Conform to this if you need to substitute a different provider type
/// (e.g., a recording provider in tests). Most consumers should just use
/// the concrete `NetworkProvider<Target>`.
public protocol NetworkProviderType: AnyObject {
    associatedtype Target: NetworkTargetType

    /// Fire-and-forget — perform the request and discard the response body.
    func perform(target: Target) async throws

    /// Perform the request and JSON-decode the body into `R`.
    func perform<R: Decodable>(target: Target, response: R.Type) async throws -> NetworkResponse<R>
}

/// The library's request executor. Generic over a `NetworkTargetType`
/// enum so that endpoint selection is checked at compile time.
///
/// Request lifecycle for each attempt:
/// 1. `target.toURLRequest()` builds a fresh `URLRequest`.
/// 2. `requestInterceptor.adapt(...)` runs every adapter in order.
/// 3. `session.data(for:)` performs the actual network call.
/// 4. `dataResponseValidator?.validate(...)` is consulted (if set).
/// 5. On `perform(target:response:)`, the body is decoded via `target.decoder`.
///
/// If any step in 1–4 fails, the retrier chain is consulted. On `.retry`
/// the whole pipeline restarts once from step 1; on `.doNotRetry` the
/// error is mapped via `Error.toNetworkError()` and rethrown.
///
/// ## Example
///
/// ```swift
/// let provider = NetworkProvider<UserAPI>(
///     session: .shared,
///     requestInterceptor: RequestInterceptor(adapters: [AuthAdapter(...)]),
///     dataResponseValidator: StatusCodeValidator()
/// )
/// let user = try await provider.perform(target: .me, response: User.self)
/// ```
public final class NetworkProvider<Target: NetworkTargetType>: NetworkProviderType {
    public let session: Session
    public let requestInterceptor: RequestInterceptor
    public let dataResponseValidator: DataResponseValidator?

    /// - Parameters:
    ///   - session: URLSession to run requests on. Defaults to `.shared`.
    ///     Inject a session with a mock `URLProtocol` for tests.
    ///   - requestInterceptor: Adapter / retrier chain. Defaults to a no-op
    ///     interceptor (no adapters, no retriers).
    ///   - dataResponseValidator: Optional response validator. When `nil`,
    ///     any 2xx-or-not response from URLSession is treated as success.
    public init(
        session: Session = .shared,
        requestInterceptor: RequestInterceptor = .init(),
        dataResponseValidator: DataResponseValidator? = .none
    ) {
        self.session = session
        self.requestInterceptor = requestInterceptor
        self.dataResponseValidator = dataResponseValidator
    }

    public func perform(target: Target) async throws {
        do {
            try await performDataRequest(target: target)
        } catch {
            throw error.toNetworkError()
        }
    }

    public func perform<R: Decodable>(
        target: Target,
        response: R.Type
    ) async throws -> NetworkResponse<R> {
        do {
            let (data, urlResponse, request) = try await performDataRequest(target: target)
            let response = try target.decoder.decode(response, from: data)
            return NetworkResponse(
                response: response,
                urlResponse: urlResponse,
                originalRequest: request
            )
        } catch {
            throw error.toNetworkError()
        }
    }
}

// MARK: - Internal request pipeline

extension NetworkProvider {
    /// Run a single request through the full pipeline, with at most one retry.
    ///
    /// - Parameter isRetrying: `true` only when invoked recursively after a
    ///   retrier triggered `.retry`. Used as the recursion base case — a
    ///   failure on the retry attempt is not re-evaluated by the chain.
    @discardableResult func performDataRequest(
        target: Target,
        isRetrying: Bool = false
    ) async throws -> (Data, URLResponse, URLRequest) {
        var request = try target.toURLRequest()
        do {
            request = try await requestInterceptor.adapt(request, for: target)
            let (data, urlResponse) = try await session.data(for: request)
            try dataResponseValidator?.validate(data, response: urlResponse).get()
            return (data, urlResponse, request)
        } catch {
            if isRetrying {
                throw error
            }
            let retryResult = try await requestInterceptor.retry(request, for: target, dueTo: error)
            switch retryResult {
            case .retry:
                return try await performDataRequest(target: target, isRetrying: true)
            case .doNotRetry:
                throw error
            }
        }
    }
}
