import Foundation

/// HTTP header fields as a flat `[String: String]` map.
///
/// Used for both per-target headers (`NetworkTargetType.headers`) and
/// the underlying `URLRequest.allHTTPHeaderFields` representation.
public typealias HTTPHeaders = [String: String]
