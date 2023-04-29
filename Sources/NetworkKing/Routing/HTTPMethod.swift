//
//  HTTPMethod.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

/// An `enum` representing HTTP methods.
public enum HTTPMethod: String, Equatable, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
