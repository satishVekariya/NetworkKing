//
//  MockTargetType.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation
import NetworkKing

enum MockTargetType: NetworkTargetType {
    case example1

    var baseURL: URL {
        URL(string: "https://api.example.com")!
    }

    var path: String {
        ""
    }

    var method: HTTPMethod {
        .get
    }
}
