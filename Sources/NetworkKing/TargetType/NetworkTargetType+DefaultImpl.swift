import Foundation

// MARK: - Defaults for the optional members of `NetworkTargetType`.
//
// Override these in your conformer only when you need a non-default value.

public extension NetworkTargetType {
    /// Default: no body, no query string.
    var task: RequestTask { .requestPlain }

    /// Default: no extra per-target headers.
    var headers: [String: String]? { .none }

    /// Default: a fresh `JSONDecoder` per call. Override to supply a
    /// configured decoder (custom date strategy, key decoding strategy, …).
    var decoder: JSONDecoder { JSONDecoder() }

    /// Build a fully-formed `URLRequest` from this target.
    ///
    /// Composition order:
    /// 1. URL = `baseURL` + `path`
    /// 2. HTTP method = `method`
    /// 3. Headers = `headers`
    /// 4. Body / query = derived from `task`
    ///
    /// `NetworkProvider` calls this internally on every attempt — including
    /// retries — so the request is always rebuilt from scratch and never
    /// carries stale state from a previous attempt.
    func toURLRequest() throws -> URLRequest {
        var request = try URLRequest(
            url: baseURL.appendingPathComponent(path),
            method: method,
            headers: headers
        )
        switch task {
        case .requestPlain:
            return request
        case let .requestData(data):
            request.httpBody = data
            return request
        case let .requestJSONEncodable(encodable):
            return try request.encoded(encodable: encodable)
        case let .requestURLQueryParameters(queryParameters):
            return try request.encoded(urlQueryItems: queryParameters)
        }
    }
}
