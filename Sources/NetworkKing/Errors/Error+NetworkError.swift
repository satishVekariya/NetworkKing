import Foundation

public extension Error {
    /// Normalize any `Error` into a `NetworkError`.
    ///
    /// Mapping:
    /// - Already a `NetworkError` → passed through unchanged.
    /// - A `DecodingError`        → wrapped as `.decodingFailed`.
    /// - Anything else            → wrapped as `.underlaying`.
    ///
    /// `NetworkProvider.perform(...)` calls this at the boundary, which
    /// is why consumers can `catch let error as NetworkError` and switch
    /// exhaustively on the cases.
    func toNetworkError() -> NetworkError {
        if let networkError = self as? NetworkError {
            return networkError
        }
        switch self {
        case let error as DecodingError:
            return .decodingFailed(error: error)
        default:
            return .underlaying(error: self)
        }
    }
}
