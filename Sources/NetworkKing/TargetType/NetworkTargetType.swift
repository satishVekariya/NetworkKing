//
//  NetworkTargetType.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

/// The protocol used to define the specifications
public protocol NetworkTargetType: URLRequestConvertible {
    /// The target's base `URL`.
    var baseURL: URL { get }
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    /// The HTTP method used in the request.
    var method: HTTPMethod { get }
    /// The type of HTTP task to be performed. Default value is `.requestPlain`.
    var task: RequestTask { get }
    /// The headers to be used in the request. Default value is `nil`.
    var headers: [String: String]? { get }
    /// The decoder to be used in the response decoding. Default value is `JSONDecoder`.
    var decoder: JSONDecoder { get }
}
