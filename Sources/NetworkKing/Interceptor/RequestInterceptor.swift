//
//  RequestInterceptor.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

/// `RequestInterceptor` which can use multiple `RequestAdapter`
public struct RequestInterceptor: RequestAdapter, RequestRetrier {
    /// All `RequestAdapter`s associated with the instance. These adapters will be run until one fails.
    public let adapters: [RequestAdapter]
    /// All `RequestRetrier`s associated with the instance. These retriers will be run one at a time until one triggers retry.
    public let retriers: [RequestRetrier]

    public init(adapters: [RequestAdapter] = [], retriers: [RequestRetrier] = []) {
        self.adapters = adapters
        self.retriers = retriers
    }

    public func adapt(_ urlRequest: URLRequest, for target: NetworkTargetType) async throws -> URLRequest {
        var urlRequest = urlRequest
        for adapter in adapters {
            urlRequest = try await adapter.adapt(urlRequest, for: target)
        }
        return urlRequest
    }

    public func retry(_ request: URLRequest, for target: NetworkTargetType, dueTo error: Error) async throws -> RetryResult {
        var finalResult = RetryResult.doNotRetry

        for retrier in retriers {
            finalResult = try await retrier.retry(request, for: target, dueTo: error)
            if finalResult == .doNotRetry {
                break
            }
        }
        return finalResult
    }
}
