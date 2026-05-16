# NetworkKing 👑

[![Swift](https://img.shields.io/badge/Swift-6.0-orange?style=flat-square)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_16+_|_macOS_13+-yellowgreen?style=flat-square)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/SPM-compatible-orange?style=flat-square)](https://swift.org/package-manager/)
[![CI](https://github.com/satishVekariya/NetworkKing/actions/workflows/swift.yml/badge.svg)](https://github.com/satishVekariya/NetworkKing/actions/workflows/swift.yml)

Type-safe, dependency-free networking on top of `URLSession`, with async/await — inspired by [Moya](https://github.com/Moya/Moya) and [Alamofire](https://github.com/Alamofire/Alamofire).

## Features

- Compile-time-checked endpoints via enums
- Async/await, strict-concurrency clean
- Request adapters & retriers (auth, logging, token refresh)
- Response validators, per-target `JSONDecoder`
- Typed `NetworkError`, zero dependencies

## Requirements

iOS 16+ · macOS 13+ · Swift 6.0 · Xcode 16+

## Installation

```swift
.package(url: "https://github.com/satishVekariya/NetworkKing.git", from: "1.0.0")
```

## Quick Start

```swift
import NetworkKing

enum TodoAPI: NetworkTargetType {
    case todo(id: Int)

    var baseURL: URL { URL(string: "https://jsonplaceholder.cypress.io")! }
    var path: String { switch self { case .todo(let id): return "/todos/\(id)" } }
    var method: HTTPMethod { .get }
}

struct Todo: Decodable { let id: Int; let title: String; let completed: Bool }

let provider = NetworkProvider<TodoAPI>()
let response = try await provider.perform(target: .todo(id: 1), response: Todo.self)
// response.value -> Todo, response.urlResponse -> URLResponse
```

## Targets

`NetworkTargetType` properties:

| Property  | Default          | Purpose                       |
|-----------|------------------|-------------------------------|
| `baseURL` | —                | Base URL                      |
| `path`    | —                | Appended to `baseURL`         |
| `method`  | —                | `.get` `.post` `.put` `.delete` |
| `task`    | `.requestPlain`  | Body / query (see below)      |
| `headers` | `nil`            | Per-request headers           |
| `decoder` | `JSONDecoder()`  | Response decoder              |

## Bodies & Query Parameters

```swift
var task: RequestTask {
    switch self {
    case .list(let page):     .requestURLQueryParameters(["page": "\(page)"])
    case .create(let user):   .requestJSONEncodable(user)
    case .raw(let data):      .requestData(data)
    case .ping:               .requestPlain
    }
}
```

## Interception

```swift
struct AuthAdapter: RequestAdapter {
    let token: () -> String?
    func adapt(_ req: URLRequest, for target: NetworkTargetType) async throws -> URLRequest {
        var r = req
        if let t = token() { r.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
        return r
    }
}

struct UnauthorizedRetrier: RequestRetrier {
    func retry(_ req: URLRequest, for target: NetworkTargetType, dueTo error: Error) async throws -> RetryResult {
        if case .responseValidationFailed = error as? NetworkError { return .retry }
        return .doNotRetry
    }
}

let provider = NetworkProvider<UserAPI>(
    requestInterceptor: RequestInterceptor(
        adapters: [AuthAdapter(token: { Keychain.token })],
        retriers: [UnauthorizedRetrier()]
    )
)
```

Adapters run in order; retriers are consulted until one returns `.retry`.

## Response Validation

```swift
struct StatusCodeValidator: DataResponseValidator {
    func validate(_ data: Data, response: URLResponse) -> Result<Void, NetworkError> {
        guard let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) else {
            return .success(())
        }
        return .failure(.responseValidationFailed(error: NSError(domain: "HTTP", code: http.statusCode)))
    }
}

let provider = NetworkProvider<UserAPI>(dataResponseValidator: StatusCodeValidator())
```

## Error Handling

```swift
do {
    let response = try await provider.perform(target: .todo(id: 1), response: Todo.self)
} catch let error as NetworkError {
    switch error {
    case .decodingFailed, .encodingFailed, .urlEncodingFailed,
         .responseValidationFailed, .underlaying: break
    }
}
```

## References

[Alamofire routing](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#routing-requests) · [Moya](https://github.com/Moya/Moya)
