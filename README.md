# NetworkKing

![Swift](https://img.shields.io/badge/Swift-5.8-orange?style=flat-square)
![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
![Platforms](https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=flat-square)

Networking is a  network abstraction layer written in Swift. It does not implement its own HTTP networking functionality. Instead it builds on top of URLSession.

##Features

✅ Compile-time checking for correct API endpoint accesses.
✅ Lets you define a clear usage of different endpoints with associated enum values.
✅ Swift's concurrency support
✅ Inspection and mutation support for each request before being start
✅ Response validation
✅ Errors handling
✅ Comprehensive Unit test coverage

##Usage

__Routing__: So how do you use this module? Well it's really simple. First set up `enum` with all your api targets. You can include information as part of your enum. For example first create a new enum MyApiTarget:

```Swift
import Networking
 
enum MyApiTarget {
    case getMyData
    //...
}
 
extension MyApiTarget: NetworkTargetType {
    var baseURL: URL {
        URL(string: "https://jsonplaceholder.cypress.io")!
    }
    var path: String {
        "/todos/1"
    }
    var method: Networking.HTTPMethod {
        .get
    }
}
```
This enum is used to make sure that you provide implementation details for each target at compile time. The enum must additionally confirm to the `NetworkTargetType` protocol like above.

Now create an instance of NetworkProvider and retain the provider somewhere. (Note that NetworkProvider is a generic class)

```Swift
let myProvider = NetworkProvider<MyApiTarget>.init()
```

Now how do we make a request? Just asynchronously call `perform` method and provide your target api (eg. .getMyData) and response type(if needed) in order to decode/map network data into your custom type(eg. User).

```Swift
struct User: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}
 
Task {
    let response = try? await myProvider.perform(target: .getMyData, response: User.self)
}
```


__RequestInterceptor__: Networking module can mutate or inspect each url request before its being made. What you needs to do is create a type that confirm to the `RequestAdapter` and pass an instance of that type into NetworkProvider's init like below:

```Swift
struct NetworkEventMonitor: RequestAdapter {
    func adapt(_ urlRequest: URLRequest, for target: NetworkTargetType) async throws -> URLRequest {
        print("NetworkEvent received with url:\n\(urlRequest.url)")
        return urlRequest
    }
}
 
 
let interceptor = RequestInterceptor(adapters: [NetworkEventMonitor(), ...])
let myProvider = NetworkProvider<UserService>.init(requestInterceptor: interceptor)
```


__DataResponseValidator__: You can also perform response validation before decoding/mapping in order to do that your type needs to confirm `DataResponseValidator` protocol which has single method requirement called validate . Inside that method you needs to make a decision about your response wether its valid or not and return your result like below:  

```Swift
struct MyCustomDataResponseValidator: DataResponseValidator {
    func validate(_ data: Data, response urlResponse: URLResponse) -> Result<Void, NetworkError> {
        if let response =  urlResponse as? HTTPURLResponse, response.statusCode == 401 {
            return .failure(.responseValidationFailed(error: NSError(domain: "Network", code: response.statusCode)))
        }
        return .success(Void())
    }
}
 
// With builtin default validator
let myProvider1 = NetworkProvider<UserService>.init(whiteHatResponseValidator: .default)
// With custom validator
let myProvider2 = NetworkProvider<UserService>.init(dataResponseValidator: MyCustomDataResponseValidator())
```


__Errors handling__: While making network requests it always possible that errors may occurred. You can catch any error thrown by perform method of NetworkProvider using traditional do {} catch {} statement.

```Swift
Task {
    do {
        let response = try await myProvider.perform(target: .getMyData, response: User.self)
        // Handle your response
    } catch let error as NetworkError {
        // Handle error
        switch error {
        case .decodingFailed(let error):
            <#code#>
        case .encodingFailed(let error):
            <#code#>
        case .underlaying(let error):
            <#code#>
        case .responseValidationFailed(let error):
            <#code#>
        }
    }
}
```

##References
Alamofire routing: https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#routing-requests

Moya: https://github.com/Moya/Moya
