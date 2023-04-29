//
//  RequestAdapter.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

public protocol RequestAdapter {
    /// Inspects and adapts the specified `URLRequest` in some manner and return new `URLRequest`.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest` to adapt.
    ///   - session:    The `Session` that will execute the `URLRequest`.
    ///   - target: The target of the request.
    /// - Returns: New `URLRequest`  or throws.
    func adapt(_ urlRequest: URLRequest, for target: NetworkTargetType) async throws -> URLRequest
}
