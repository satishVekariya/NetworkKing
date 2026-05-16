import Foundation

public extension URLRequest {
    /// JSON-encode `encodable` into the request body and set
    /// `Content-Type: application/json` (unless the caller has already set it).
    ///
    /// - Parameters:
    ///   - encodable: The value to encode.
    ///   - encoder:   Encoder to use. Defaults to `JSONEncoder()`. Pass a
    ///                configured encoder when you need a custom date / key strategy.
    /// - Returns:     `self`, for chaining.
    /// - Throws:      `NetworkError.encodingFailed` wrapping the underlying
    ///                `EncodingError`.
    mutating func encoded(encodable: Encodable, encoder: JSONEncoder = .init()) throws -> URLRequest {
        do {
            setContentTypeApplicationJsonHeaderIfNeeded()
            httpBody = try encoder.encode(encodable)
            return self
        } catch {
            throw NetworkError.encodingFailed(error: error)
        }
    }

    /// Replace the request's query string with the supplied items.
    ///
    /// A `nil` value renders the key without `=` (e.g., `["flag": nil]` → `?flag`).
    /// Existing query items on the URL are replaced.
    ///
    /// - Throws: `NetworkError.urlEncodingFailed` if the request has no URL.
    mutating func encoded(urlQueryItems: [String: String?]) throws -> URLRequest {
        guard let url else {
            throw NetworkError.urlEncodingFailed(reason: "missing url")
        }
        let queryItems = urlQueryItems
            .enumerated()
            .map { URLQueryItem(name: $0.element.key, value: $0.element.value) }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems
        self.url = components?.url
        return self
    }

    /// Set `Content-Type: application/json` only if the header is not already set.
    /// Lets callers override with a custom JSON variant (e.g., `application/vnd.x+json`).
    mutating func setContentTypeApplicationJsonHeaderIfNeeded() {
        if value(forHTTPHeaderField: "Content-Type") == nil {
            setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
