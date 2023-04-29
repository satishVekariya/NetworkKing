//
//  NetworkResponse.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

/// Generic `struct` to represent response received from network.
public struct NetworkResponse<R: Decodable> {
    public let response: R
    public let urlResponse: URLResponse
    public let originalRequest: URLRequest
}
