//
//  URLRequest+Encoding.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

public extension URLRequest {
    mutating func encoded(encodable: Encodable, encoder: JSONEncoder = .init()) throws -> URLRequest {
        do {
            setContentTypeApplicationJsonHeaderIfNeeded()
            httpBody = try encoder.encode(encodable)
            return self
        } catch {
            throw NetworkError.encodingFailed(error: error)
        }
    }

    mutating func encoded(urlQueryItems: [String: String?]) throws -> URLRequest {
        guard let url else {
            throw NetworkError.urlEncodingFailed(reason: "missing url")
        }
        let queryItems = urlQueryItems
            .enumerated()
            .map { URLQueryItem(name: $0.element.key, value: $0.element.value) }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems
        self.url = components?.url
        return self
    }

    mutating func setContentTypeApplicationJsonHeaderIfNeeded() {
        if value(forHTTPHeaderField: "Content-Type") == nil {
            setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
