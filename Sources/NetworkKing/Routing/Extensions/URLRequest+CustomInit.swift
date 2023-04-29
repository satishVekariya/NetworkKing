//
//  URLRequest+CustomInit.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

public extension URLRequest {
    /// Construct a `URLRequest` with the `URL`, `method`, and `headers`.
    ///
    /// - Parameters:
    ///   - url:     The `URL` value.
    ///   - method:  The `HTTPMethod`.
    ///   - headers: The `HTTPHeaders`,  default `nil`.
    /// - Throws:    Any error thrown while converting the `URLConvertible` to a `URL`.
    init(url: URL, method: HTTPMethod, headers: HTTPHeaders? = nil) throws {
        self.init(url: url)
        httpMethod = method.rawValue
        allHTTPHeaderFields = headers
    }
}
