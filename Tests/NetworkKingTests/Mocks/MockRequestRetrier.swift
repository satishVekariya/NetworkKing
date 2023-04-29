//
//  MockRequestRetrier.swift
//  
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation
import NetworkKing

struct MockRequestRetrier: RequestRetrier {
    typealias Block = (_ request: URLRequest, _ target: NetworkTargetType, _ error: Error) async throws -> RetryResult
    
    let block: Block

    func retry(_ request: URLRequest, for target: NetworkTargetType, dueTo error: Error) async throws -> RetryResult {
        try await block(request, target, error)
    }
}
