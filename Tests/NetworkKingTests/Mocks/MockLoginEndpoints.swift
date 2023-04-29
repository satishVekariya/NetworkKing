//
//  MockLoginEndpoints.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation
import NetworkKing

enum MockLoginEndpoints {
    case login(id: String, pass: String)
    case getUser(userId: String)
}

extension MockLoginEndpoints: NetworkTargetType {
    static let url = URL(string: "http://api.domian.com")!

    var baseURL: URL {
        Self.url
    }

    var path: String {
        switch self {
        case .login:
            return "/login"
        case let .getUser(userId: userId):
            return "/user/\(userId)"
        }
    }

    var method: Networking.HTTPMethod {
        switch self {
        case .login:
            return .post
        case .getUser:
            return .get
        }
    }

    var task: RequestTask {
        switch self {
        case let .login(id, pass):
            return .requestJSONEncodable(MockLoginData(username: id, password: pass))
        case let .getUser(userId):
            return .requestURLQueryParameters(["userId": userId])
        }
    }
}

struct MockDataResponseValidator: DataResponseValidator {
    let block: () -> Result<Void, Networking.NetworkError>
    func validate(_: Data, response _: URLResponse) -> Result<Void, Networking.NetworkError> {
        block()
    }
}

struct MockLoginData: Codable, Equatable {
    let username: String
    let password: String
}

struct MockUserObject: Codable, Equatable {
    let id: String
    let name: String
    let age: Int
}
