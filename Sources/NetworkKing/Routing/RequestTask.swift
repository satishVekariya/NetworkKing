import Foundation

/// Describes how the body / query string of a request is built.
///
/// Choose the case that matches your endpoint's expected payload:
///
/// - `.requestPlain` — no body and no query string (typical for GETs).
/// - `.requestData(Data)` — set the body to raw bytes verbatim.
///   Use for binary uploads (images, protobuf, multipart you've already serialized).
/// - `.requestJSONEncodable(Encodable)` — JSON-encode an `Encodable`
///   value and set `Content-Type: application/json` if not already set.
/// - `.requestURLQueryParameters([String: String?])` — append items to
///   the URL's query string. A `nil` value renders as a bare key (`?flag`).
///
/// ## Example
///
/// ```swift
/// var task: RequestTask {
///     switch self {
///     case .listUsers(let page):
///         return .requestURLQueryParameters(["page": "\(page)"])
///     case .createUser(let user):
///         return .requestJSONEncodable(user)
///     case .uploadAvatar(let png):
///         return .requestData(png)
///     case .ping:
///         return .requestPlain
///     }
/// }
/// ```
public enum RequestTask {
    /// A request with no body and no query parameters.
    case requestPlain

    /// A request body set to raw `Data` verbatim.
    case requestData(Data)

    /// A request body produced by JSON-encoding an `Encodable` value.
    /// Sets `Content-Type: application/json` unless the caller has set it.
    case requestJSONEncodable(Encodable)

    /// URL query items appended to the request URL.
    /// A `nil` value yields a bare key (`?flag`).
    case requestURLQueryParameters([String: String?])
}
