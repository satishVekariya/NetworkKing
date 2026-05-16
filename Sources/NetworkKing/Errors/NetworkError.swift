import Foundation

/// All errors thrown by `NetworkProvider.perform(...)`.
///
/// Catch `NetworkError` to handle networking failures with a typed switch;
/// the underlying error is always preserved in the associated value for
/// logging or recovery.
///
/// ## Example
///
/// ```swift
/// do {
///     let user = try await provider.perform(target: .me, response: User.self)
/// } catch let error as NetworkError {
///     switch error {
///     case .decodingFailed(let underlying):          // response body didn't match the model
///     case .encodingFailed(let underlying):          // request body couldn't be encoded
///     case .urlEncodingFailed(let reason):           // URL / query couldn't be formed
///     case .responseValidationFailed(let underlying):// validator rejected the response
///     case .underlaying(let underlying):             // transport or other unknown error
///     }
/// }
/// ```
public enum NetworkError: Error, @unchecked Sendable {
    /// JSON decoding of the response body failed.
    case decodingFailed(error: Error)

    /// JSON encoding of the request body failed.
    case encodingFailed(error: Error)

    /// URL / query string could not be constructed (e.g., request had no URL).
    case urlEncodingFailed(reason: String)

    /// A non-`NetworkError`, non-`DecodingError` propagated through the stack
    /// (typically a `URLError` from transport).
    case underlaying(error: Error)

    /// A `DataResponseValidator` returned `.failure`.
    /// Associated value is the validator's underlying error, if any.
    case responseValidationFailed(error: Error?)
}

extension NetworkError: LocalizedError {
    /// Human-readable description that always surfaces the underlying error or
    /// reason — safe to log directly.
    public var errorDescription: String? {
        switch self {
        case let .decodingFailed(error):
            return "Response could not be decoded because of error:\n\(error.localizedDescription)"
        case let .encodingFailed(error):
            return "Request could not be encoded because of error:\n\(error.localizedDescription)"
        case let .urlEncodingFailed(reason):
            return "Request could not be encoded because of:\n\(reason)"
        case let .underlaying(error):
            return "Underlaying error:\n\(error)"
        case let .responseValidationFailed(error):
            return "Response validation failed because of error:\n\(error?.localizedDescription ?? "unknown error")"
        }
    }
}
