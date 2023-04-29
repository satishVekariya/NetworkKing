//
//  RequestRetrier.swift
//  
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

/// A type that determines whether a request should be retried after being executed by the specified session manager and encountering an error.
public protocol RequestRetrier {
    /// Determines whether the `URLRequest` should be retried by returning the `RetryResult` enum value.
    /// - Parameters:
    ///   - request: `URLRequest` that failed due to the provided `Error`.
    ///   - target: The target of the request.
    ///   - error: `Error` encountered while executing the `URLRequest`.
    /// - Returns: An enum value to be returned when a retry decision has been determined.
    func retry(_ request: URLRequest, for target: NetworkTargetType, dueTo error: Error) async throws -> RetryResult
}

public enum RetryResult {
    /// Retry should be attempted immediately.
    case retry
    /// Do not retry.
    case doNotRetry
}
