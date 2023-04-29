//
//  NetworkTargetType+DefaultImplTests.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

@testable import NetworkKing
import XCTest

final class NetworkTargetTypeDefaultImplTest: XCTestCase {
    func testDefaultHeaders() {
        let target = TargetWithDefaultImpl.case1
        XCTAssertEqual(target.headers, .none)
    }

    func testDefaultTask() {
        let target = TargetWithDefaultImpl.case1

        switch target.task {
        case .requestPlain:
            /// requestPlain is expected task type
            break
        default:
            XCTFail("Invalid default task, it should be .requestPlain")
        }
    }

    /// Target type with default implementation
    enum TargetWithDefaultImpl: NetworkTargetType {
        case case1

        var baseURL: URL {
            URL(string: "")!
        }

        var path: String {
            ""
        }

        var method: Networking.HTTPMethod {
            .get
        }
    }
}
