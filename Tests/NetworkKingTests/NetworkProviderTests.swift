import Foundation
import Testing
@testable import NetworkKing

@Suite("NetworkProvider", .serialized)
struct NetworkProviderTests {

    private static func makeSession() -> Session {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return Session(configuration: config)
    }

    private static func okResponse(data: Data? = nil) {
        URLProtocolMock.onStartLoading = {
            let response = HTTPURLResponse(
                url: MockLoginEndpoints.url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }
    }

    init() { URLProtocolMock.reset() }

    @Test("POST request runs adapter and validator")
    func postWithValidation() async throws {
        let adaptCount = TestBox(0)
        let validateCount = TestBox(0)
        let adapter = MockAdapter(httpHeaders: [:]) { adaptCount.value += 1 }
        let validator = MockDataResponseValidator {
            validateCount.value += 1
            return .success(())
        }
        let provider = NetworkProvider<MockLoginEndpoints>(
            session: Self.makeSession(),
            requestInterceptor: .init(adapters: [adapter]),
            dataResponseValidator: validator
        )
        Self.okResponse()

        try await provider.perform(target: .login(id: "user", pass: "pass"))

        #expect(adaptCount.value == 1)
        #expect(validateCount.value == 1)
    }

    @Test("Validation failure surfaces as NetworkError.responseValidationFailed")
    func validationFailureSurfaces() async {
        let validator = MockDataResponseValidator {
            .failure(.responseValidationFailed(error: NSError(domain: "v", code: 7)))
        }
        let provider = NetworkProvider<MockLoginEndpoints>(
            session: Self.makeSession(),
            dataResponseValidator: validator
        )
        Self.okResponse()

        await #expect(throws: NetworkError.self) {
            try await provider.perform(target: .login(id: "u", pass: "p"))
        }
    }

    @Test("GET request decodes response body via target's decoder")
    func getDecodesResponse() async throws {
        let body = #"{"id":"123","name":"Xyz","age":18}"#.data(using: .utf8)!
        let provider = NetworkProvider<MockLoginEndpoints>(session: Self.makeSession())
        Self.okResponse(data: body)

        let response = try await provider.perform(target: .getUser(userId: "123"), response: MockUserObject.self)
        #expect(response.response == MockUserObject(id: "123", name: "Xyz", age: 18))
    }

    @Test("Returned NetworkResponse exposes URLResponse and originalRequest")
    func networkResponseWrapping() async throws {
        let body = #"{"id":"1","name":"a","age":1}"#.data(using: .utf8)!
        let provider = NetworkProvider<MockLoginEndpoints>(session: Self.makeSession())
        Self.okResponse(data: body)

        let response = try await provider.perform(target: .getUser(userId: "1"), response: MockUserObject.self)
        #expect((response.urlResponse as? HTTPURLResponse)?.statusCode == 200)
        #expect(response.originalRequest.url != nil)
    }

    @Test("Decoding failure surfaces as NetworkError.decodingFailed")
    func decodingFailureSurfaces() async {
        let body = "not-json".data(using: .utf8)!
        let provider = NetworkProvider<MockLoginEndpoints>(session: Self.makeSession())
        Self.okResponse(data: body)

        do {
            _ = try await provider.perform(target: .getUser(userId: "1"), response: MockUserObject.self)
            Issue.record("expected decoding failure to throw")
        } catch let error as NetworkError {
            guard case .decodingFailed = error else {
                Issue.record("expected .decodingFailed, got \(error)")
                return
            }
        } catch {
            Issue.record("unexpected error type \(error)")
        }
    }

    @Test("Retrier .retry triggers a second request which then succeeds")
    func retryThenSucceeds() async throws {
        let body = #"{"id":"1","name":"a","age":1}"#.data(using: .utf8)!
        let attemptCount = TestBox(0)
        URLProtocolMock.onStartLoading = {
            attemptCount.value += 1
            let code = attemptCount.value == 1 ? 500 : 200
            let response = HTTPURLResponse(
                url: MockLoginEndpoints.url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, body)
        }
        let validator = MockDataResponseValidator {
            // Read the count to decide; first call fails, second passes
            attemptCount.value == 1
                ? .failure(.responseValidationFailed(error: nil))
                : .success(())
        }
        let retryCount = TestBox(0)
        let retrier = MockRequestRetrier { _, _, _ in
            retryCount.value += 1
            return .retry
        }
        let provider = NetworkProvider<MockLoginEndpoints>(
            session: Self.makeSession(),
            requestInterceptor: .init(retriers: [retrier]),
            dataResponseValidator: validator
        )

        let response = try await provider.perform(target: .getUser(userId: "1"), response: MockUserObject.self)
        #expect(response.response.id == "1")
        #expect(attemptCount.value == 2)
        #expect(retryCount.value == 1)
    }

    @Test("Retry recursion stops after one retry attempt")
    func retryRecursionTerminates() async {
        let attemptCount = TestBox(0)
        URLProtocolMock.onStartLoading = {
            attemptCount.value += 1
            let response = HTTPURLResponse(
                url: MockLoginEndpoints.url,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, nil)
        }
        let validator = MockDataResponseValidator {
            .failure(.responseValidationFailed(error: nil))
        }
        let retrier = MockRequestRetrier { _, _, _ in .retry }
        let provider = NetworkProvider<MockLoginEndpoints>(
            session: Self.makeSession(),
            requestInterceptor: .init(retriers: [retrier]),
            dataResponseValidator: validator
        )

        await #expect(throws: NetworkError.self) {
            try await provider.perform(target: .login(id: "u", pass: "p"))
        }
        #expect(attemptCount.value == 2)
    }

    @Test("Provider works without a validator")
    func noValidator() async throws {
        let body = #"{"id":"1","name":"a","age":1}"#.data(using: .utf8)!
        let provider = NetworkProvider<MockLoginEndpoints>(session: Self.makeSession())
        Self.okResponse(data: body)
        let response = try await provider.perform(target: .getUser(userId: "1"), response: MockUserObject.self)
        #expect(response.response.id == "1")
    }
}
