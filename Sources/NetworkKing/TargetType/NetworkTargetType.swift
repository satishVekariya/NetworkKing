import Foundation

/// The contract every API endpoint must conform to.
///
/// Group an API's endpoints in a single enum and conform that enum to
/// `NetworkTargetType`. The compiler then guarantees that every case
/// supplies a `baseURL`, `path`, and `method`. Optional members
/// (`task`, `headers`, `decoder`) have sensible defaults provided by an
/// extension — override only when you need to.
///
/// ## Example
///
/// ```swift
/// enum UserAPI: NetworkTargetType {
///     case list(page: Int)
///     case create(User)
///
///     var baseURL: URL { URL(string: "https://api.example.com")! }
///     var path: String {
///         switch self {
///         case .list:   return "/users"
///         case .create: return "/users"
///         }
///     }
///     var method: HTTPMethod {
///         switch self {
///         case .list:   return .get
///         case .create: return .post
///         }
///     }
///     var task: RequestTask {
///         switch self {
///         case .list(let page):   return .requestURLQueryParameters(["page": "\(page)"])
///         case .create(let user): return .requestJSONEncodable(user)
///         }
///     }
/// }
/// ```
public protocol NetworkTargetType: URLRequestConvertible {
    /// Base URL of the API. Combined with `path` to form the full URL.
    var baseURL: URL { get }

    /// Path component appended to `baseURL`. Should start with `/`.
    var path: String { get }

    /// HTTP method used for the request.
    var method: HTTPMethod { get }

    /// Body / query specification. Default: `.requestPlain`.
    var task: RequestTask { get }

    /// Per-request headers. Default: `nil` (no extra headers).
    /// Note: adapters can override these later in the pipeline.
    var headers: [String: String]? { get }

    /// JSON decoder applied to the response body before returning.
    /// Default: a fresh `JSONDecoder()`. Override per target when you
    /// need a custom date / key-decoding strategy.
    var decoder: JSONDecoder { get }
}
