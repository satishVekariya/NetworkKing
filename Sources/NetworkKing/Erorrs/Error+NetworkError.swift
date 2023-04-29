//
//  Error+NetworkError.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

public extension Error {
    /// Convert error instance into `NetworkError`
    /// - Returns: Instance of `NetworkError`
    func toNetworkError() -> NetworkError {
        if let networkError = self as? NetworkError {
            return networkError
        }
        switch self {
        case let error as DecodingError:
            return .decodingFailed(error: error)
        default:
            return .underlaying(error: self)
        }
    }
}
