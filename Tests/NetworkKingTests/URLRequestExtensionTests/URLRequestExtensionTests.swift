//
//  URLRequestExtensionTests.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation
import NetworkKing
import XCTest

final class URLRequestExtensionTests: XCTestCase {
    let url = URL(string: "http://api.test.com")!
    func testInitWithURLHeadersAndMethod() throws {
        let headers = ["Content-Type": "xyz"]

        for method in HTTPMethod.allCases {
            let request = try URLRequest(url: url, method: method, headers: headers)

            /// Check request url
            let requestUrl = try XCTUnwrap(request.url)
            XCTAssertEqual(requestUrl, url)

            /// Check request headers
            let requestHeaders = try XCTUnwrap(request.allHTTPHeaderFields)
            XCTAssertEqual(requestHeaders, headers)
        }
    }

    func testEncodedWithEncodable() throws {
        var request = URLRequest(url: url)
        let encodable = CustomEncodable(field1: "StringVal", field2: 123, field3: true, field4: 1.4)
        request = try request.encoded(encodable: encodable)

        let allHeaders = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertTrue(allHeaders["Content-Type"] == "application/json")

        let httpBody = try XCTUnwrap(request.httpBody)
        let decodedObject = try JSONDecoder().decode(CustomEncodable.self, from: httpBody)
        XCTAssertEqual(encodable, decodedObject)
    }

    struct CustomEncodable: Codable, Equatable {
        let field1: String
        let field2: Int
        let field3: Bool
        let field4: Double
    }

    func testEncodedUrlQueryItems() throws {
        var request = URLRequest(url: url)
        request = try request.encoded(urlQueryItems: ["q1": "val1", "q2": "val2"])
        let url = try XCTUnwrap(request.url)
        let range = url.absoluteString.range(of: #"q2=val2&q1=val1|q1=val1&q2=val2"#, options: .regularExpression)
        XCTAssertNotNil(range)
    }

    func testSetContentTypeApplicationJsonHeaderIfNeeded() throws {
        var request = URLRequest(url: url)
        request.setContentTypeApplicationJsonHeaderIfNeeded()
        let allHeaders = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertTrue(allHeaders["Content-Type"] == "application/json")
    }
}
