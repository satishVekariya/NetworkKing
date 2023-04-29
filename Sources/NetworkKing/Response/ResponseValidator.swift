//
//  ResponseValidator.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

public protocol DataResponseValidator {
    /// Validate the specified `Data` & `URLResponse` in some manner and return a result.
    /// - Parameters:
    ///   - data: Instance of `Data` received from network
    ///   - urlResponse: Instance of `URLResponse` received from network
    /// - Returns: Validated result.
    func validate(_ data: Data, response urlResponse: URLResponse) -> Result<Void, NetworkError>
}
