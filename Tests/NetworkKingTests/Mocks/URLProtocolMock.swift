//
//  URLProtocolMock.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation
@testable import NetworkKing

/// URL protocol mock
///
/// More info: https://www.hackingwithswift.com/articles/153/how-to-test-ios-networking-code-the-easy-way
class URLProtocolMock: URLProtocol {
    nonisolated(unsafe) static var onStartLoading: (@Sendable () -> (HTTPURLResponse, Data?))?

    static func reset() {
        onStartLoading = nil
    }

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let onStartLoading = Self.onStartLoading else {
            fatalError("URLProtocolMock.onStartLoading must be set before issuing a request")
        }
        let (response, data) = onStartLoading()

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let data {
            client?.urlProtocol(self, didLoad: data)
        }

        // mark that we've finished
        client?.urlProtocolDidFinishLoading(self)
    }

    // this method is required but doesn't need to do anything
    override func stopLoading() {}
}
