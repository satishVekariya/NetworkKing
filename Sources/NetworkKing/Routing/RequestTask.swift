//
//  RequestTask.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import Foundation

/// Represents an HTTP task.
public enum RequestTask {
    /// A request with no additional data.
    case requestPlain

    /// A request body set with data.
    case requestData(Data)

    /// A request body set with `Encodable` type
    case requestJSONEncodable(Encodable)

    /// A request url with encoded query string
    case requestURLQueryParameters([String: String?])
}
