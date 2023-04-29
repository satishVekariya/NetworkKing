//
//  RequestInterceptorTests.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

@testable import NetworkKing
import XCTest

final class RequestInterceptorTests: XCTestCase {
    func testAdapt() async throws {
        let header: (key: String, value: String) = ("Content-Type", "XYZ")

        var adaptMethodInvokeCount = 0

        let adapter = MockAdapter(httpHeaders: [header.key: header.value]) {
            adaptMethodInvokeCount += 1
        }
        let interceptor = RequestInterceptor(adapters: [adapter])

        let target = MockTargetType.example1
        let request = try target.toURLRequest()

        // Perform invoke
        let newRequest = try await interceptor.adapt(request, for: target)

        XCTAssertEqual(adaptMethodInvokeCount, 1)
        let newHeaders = newRequest.allHTTPHeaderFields ?? [:]
        XCTAssertTrue(newHeaders[header.key] == header.value)
    }

    func testRetry() async throws {
        let originalRequest = URLRequest(url: URL(string: "http://test.com/abc")!)
        let originalTarget = MockTargetType.example1
        let originalError = NSError(domain: "test", code: 11)
        var result = RetryResult.doNotRetry

        let retrier = MockRequestRetrier { request, target, error in
            XCTAssertEqual(request, originalRequest)
            XCTAssertEqual(target as! MockTargetType, originalTarget)
            XCTAssertEqual(error as NSError, originalError)
            return result
        }
        let interceptor = RequestInterceptor(retriers: [retrier])

        let finalResult1 = try await interceptor.retry(originalRequest, for: originalTarget, dueTo: originalError)
        XCTAssertEqual(finalResult1, .doNotRetry)

        result = .retry
        let finalResult2 = try await interceptor.retry(originalRequest, for: originalTarget, dueTo: originalError)

        XCTAssertEqual(finalResult2, .retry)
    }
}
