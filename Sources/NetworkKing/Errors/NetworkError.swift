//
//  NetworkError.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

public enum NetworkError: Error {
    case decodingFailed(error: Error)
    case encodingFailed(error: Error)
    case urlEncodingFailed(reason: String)
    case underlaying(error: Error)
    case responseValidationFailed(error: Error?)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .decodingFailed(error):
            return "Response could not be decoded because of error:\n\(error.localizedDescription)"
        case let .encodingFailed(error):
            return "Request could not be encoded because of error:\n\(error.localizedDescription)"
        case let .urlEncodingFailed(reason):
            return "Request could not be encoded because of:\n\(reason)"
        case let .underlaying(error):
            return "Underlaying error:\n\(error)"
        case let .responseValidationFailed(error):
            return "Response validation failed because of error:\n\(error?.localizedDescription ?? "unknown error")"
        }
    }
}
