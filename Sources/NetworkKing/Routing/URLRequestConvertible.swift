//
//  URLRequestConvertible.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

/// A protocol that can be used to  construct `URLRequest`.
public protocol URLRequestConvertible {
    /// Construct a `URLRequest` from the conforming object or throws.
    ///
    /// - Returns: A `URLRequest`.
    /// - Throws:  Any error thrown while constructing the `URLRequest`.
    func toURLRequest() throws -> URLRequest
}

public extension URLRequestConvertible {
    /// An optional`URLRequest` returned by ignoring  any `Error`.
    var urlRequest: URLRequest? {
        try? toURLRequest()
    }
}
