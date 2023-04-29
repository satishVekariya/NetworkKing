//
//  NetworkProvider.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

public typealias Session = URLSession

public protocol NetworkProviderType: AnyObject {
    associatedtype Target: NetworkTargetType

    /// Perform a network api call. Like fire and forget
    /// - Parameter target: Endpoint target
    func perform(target: Target) async throws

    /// Perform network request with response mapping
    /// - Parameters:
    ///   - target: The Endpoint target
    ///   - response: A response type to be used to decode network data.
    /// - Returns: An `NetworkResponse` instance
    func perform<R: Decodable>(target: Target, response: R.Type) async throws -> NetworkResponse<R>
}

public final class NetworkProvider<Target: NetworkTargetType>: NetworkProviderType {
    public let session: Session
    public let requestInterceptor: RequestInterceptor
    public let dataResponseValidator: DataResponseValidator?

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
            // Decode response data
            let response = try target.decoder.decode(response, from: data)
            // Return response
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

// MARK: NetworkProvider internal

extension NetworkProvider {
    /// Perform data request with request interceptor and response validator
    /// - Parameter target: The Endpoint target
    /// - Returns: Instance of `Data`, `URLResponse` and `URLRequest` or throws.
    @discardableResult func performDataRequest(
        target: Target,
        isRetrying: Bool = false
    ) async throws -> (Data, URLResponse, URLRequest) {
        // 1. Build url request
        var request = try target.toURLRequest()
        do {
            // 2. Invoke request interceptor. e.g set access-token or monitor request etc.
            request = try await requestInterceptor.adapt(request, for: target)
            // 3. Perform network data request
            let (data, urlResponse) = try await session.data(for: request)
            // 4. Perform response validation if available.
            try dataResponseValidator?.validate(data, response: urlResponse).get()
            // Return data & response
            return (data, urlResponse, request)
        } catch {
            if isRetrying {
                /// End recursion
                throw error
            }
            /// Check for retry
            let retryResult = try await requestInterceptor.retry(request, for: target, dueTo: error)
            switch retryResult {
            case .retry:
                /// Start recursion
                return try await performDataRequest(target: target, isRetrying: true)
            case .doNotRetry:
                throw error
            }
        }
    }
}
