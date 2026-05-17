# ``NetworkKing``

Type-safe, dependency-free networking on top of `URLSession`, with async/await.

## Overview

NetworkKing is a thin abstraction over `URLSession` that gives you:

- Compile-time-checked endpoints described as enum cases.
- Pluggable request adapters (auth, logging, signing) and retriers
  (token refresh, transient failure recovery).
- A response validator hook that runs before decoding.
- Typed errors via ``NetworkError``.
- Zero external dependencies.

The pipeline executed by ``NetworkProvider`` for every attempt:

1. ``URLRequestConvertible/toURLRequest()`` builds a fresh `URLRequest`.
2. ``RequestInterceptor/adapt(_:for:)`` pipes it through every adapter
   in order.
3. `URLSession.data(for:)` performs the call.
4. ``DataResponseValidator/validate(_:response:)`` is consulted (if set).
5. The response body is JSON-decoded with the target's ``NetworkTargetType/decoder``.

On failure, the retrier chain runs once — stopping at the first
``RetryResult/retry``. A retried attempt is not re-evaluated by the
chain (one retry max).

## Topics

### Defining endpoints

- ``NetworkTargetType``
- ``URLRequestConvertible``
- ``HTTPMethod``
- ``HTTPHeaders``
- ``RequestTask``

### Executing requests

- ``NetworkProvider``
- ``NetworkProviderType``
- ``Session``
- ``NetworkResponse``

### Interception

- ``RequestInterceptor``
- ``RequestAdapter``
- ``RequestRetrier``
- ``RetryResult``

### Validation

- ``DataResponseValidator``

### Errors

- ``NetworkError``

## Quick Start

```swift
import NetworkKing

enum TodoAPI: NetworkTargetType {
    case todo(id: Int)

    var baseURL: URL { URL(string: "https://jsonplaceholder.cypress.io")! }
    var path: String {
        switch self { case .todo(let id): return "/todos/\(id)" }
    }
    var method: HTTPMethod { .get }
}

struct Todo: Decodable { let id: Int; let title: String; let completed: Bool }

let provider = NetworkProvider<TodoAPI>()
let response = try await provider.perform(target: .todo(id: 1), response: Todo.self)
```
