//
//  Error+NetworkErrorTests.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

@testable import NetworkKing
import XCTest

final class ErrorNetworkErrorTest: XCTestCase {
    func testToNetworkErrorForNetworkError() {
        /// Check network errors ([Errors]) to NetworkError mapping
        let errors: [Error] = [
            NetworkError.decodingFailed(error: NSError()),
            NetworkError.encodingFailed(error: NSError()),
            NetworkError.urlEncodingFailed(reason: ""),
            NetworkError.responseValidationFailed(error: NSError()),
        ]
        for error in errors {
            let networkError = error.toNetworkError()
            if case .underlaying = networkError {
                XCTFail("Expecting other then underlaying")
            }
        }
        /// Check underlying error mapping
        let underlyingError: Error = NetworkError.underlaying(error: NSError())
        switch underlyingError.toNetworkError() {
        case .underlaying:
            /// underlaying case expected
            break
        default:
            XCTFail("error should be mapped as underlyingError")
        }
    }

    func testToNetworkErrorForDecodingError() {
        let context = DecodingError.Context(codingPath: [], debugDescription: "")
        enum DummyCodingKeys: CodingKey {
            case none
        }
        let decodingError: [Error] = [
            DecodingError.dataCorrupted(context),
            DecodingError.typeMismatch(Void.self, context),
            DecodingError.valueNotFound(Void.self, context),
            DecodingError.keyNotFound(DummyCodingKeys.none, context),
        ]

        for error in decodingError {
            let mappedError = error.toNetworkError()
            switch mappedError {
            case .decodingFailed:
                /// decodingFailed case expected
                break
            default:
                XCTFail("error should be mapped as decoding error")
            }
        }
    }
}
