//
//  MockAdapter.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation
@testable import NetworkKing

struct MockAdapter: RequestAdapter {
    let httpHeaders: [String: String]
    let block: () async -> Void

    func adapt(_ urlRequest: URLRequest, for _: NetworkTargetType) async throws -> URLRequest {
        var urlRequest = urlRequest

        let allHeader = (urlRequest.allHTTPHeaderFields ?? [:]).merging(httpHeaders) { _, new in
            new
        }
        urlRequest.allHTTPHeaderFields = allHeader

        await block()

        return urlRequest
    }
}

let r = RequestInterceptor(adapters: [])
