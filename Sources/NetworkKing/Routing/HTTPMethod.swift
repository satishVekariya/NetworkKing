import Foundation

/// HTTP verbs supported by `NetworkTargetType`.
///
/// The raw value is what gets assigned to `URLRequest.httpMethod`.
/// Add a case here only when adding support for a new HTTP verb across
/// the package.
public enum HTTPMethod: String, Equatable, CaseIterable, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
