//
//  URLProtocolMock.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation
@testable import NetworkKing
import XCTest

/// URL protocol mock
///
/// More info: https://www.hackingwithswift.com/articles/153/how-to-test-ios-networking-code-the-easy-way
class URLProtocolMock: URLProtocol {
    static var onStartLoading: (() -> (HTTPURLResponse, Data?))?

    // say we want to handle all types of request
    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    // ignore this method; just send back what we were given
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let onStartLoading = Self.onStartLoading else {
            XCTFail("Set onStartLoading handler.")
            return
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
