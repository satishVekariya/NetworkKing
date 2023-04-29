//
//  NetworkTargetType+DefaultImpl.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

// MARK: - Default implementation for `NetworkTargetType`

public extension NetworkTargetType {
    var task: RequestTask {
        .requestPlain
    }

    var headers: [String: String]? {
        .none
    }

    var decoder: JSONDecoder {
        JSONDecoder()
    }

    func toURLRequest() throws -> URLRequest {
        var request = try URLRequest(
            url: baseURL.appendingPathComponent(path),
            method: method,
            headers: headers
        )
        switch task {
        case .requestPlain:
            return request
        case let .requestData(data):
            request.httpBody = data
            return request
        case let .requestJSONEncodable(encodable):
            return try request.encoded(encodable: encodable)
        case let .requestURLQueryParameters(queryParameters):
            return try request.encoded(urlQueryItems: queryParameters)
        }
    }
}
