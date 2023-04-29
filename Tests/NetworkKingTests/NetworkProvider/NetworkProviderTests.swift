//
//  NetworkProviderTests.swift
//
//
//  Created by Satish Vekariya on 29/04/2023.
//

import NetworkKing
import XCTest

final class NetworkProviderTests: XCTestCase {
    var mockSession: Session!

    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        mockSession = Session(configuration: config)
    }

    func testPerformPostRequestWithValidation() async throws {
        /// Interceptor
        let adaptMethodInvoke = expectation(description: "Adapter method invoked")
        adaptMethodInvoke.expectedFulfillmentCount = 2
        let adapter = MockAdapter(httpHeaders: [:]) {
            adaptMethodInvoke.fulfill()
        }

        /// Response validator
        var validationResult: Result<Void, NetworkError>!
        let validationInvoked = expectation(description: "Validation method invoked")
        validationInvoked.expectedFulfillmentCount = 2
        let validator = MockDataResponseValidator {
            validationInvoked.fulfill()
            return validationResult
        }

        /// Construct provider with interceptor & validator
        let provider = NetworkProvider<MockLoginEndpoints>(
            session: mockSession!,
            requestInterceptor: .init(adapters: [adapter]),
            dataResponseValidator: validator
        )

        let requestReceivedExp = expectation(description: "Network request received")
        requestReceivedExp.expectedFulfillmentCount = 2
        URLProtocolMock.onStartLoading = {
            let response = HTTPURLResponse(
                url: MockLoginEndpoints.url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            requestReceivedExp.fulfill()
            return (response, nil)
        }

        /// Execute post request
        validationResult = .success(())
        try await provider.perform(target: .login(id: "user.name", pass: "Test@1234"))

        /// Execute post request with validation failure
        let validationErrorExp = expectation(description: "Expecting validation error")
        do {
            validationResult = .failure(.responseValidationFailed(error: .none))
            try await provider.perform(target: .login(id: "user.name", pass: "Test@1234"))
            XCTFail("Perform method should throws an error for validation result: \(String(describing: validationResult))")
        } catch {
            validationErrorExp.fulfill()
        }
        let exceptions = [adaptMethodInvoke, requestReceivedExp, validationInvoked, validationErrorExp]
        await fulfillment(of: exceptions, timeout: 3)
    }

    func testPerformGetRequestWithValidation() async throws {
        /// Interceptor
        let adaptMethodInvoke = expectation(description: "Adapter method invoked")
        adaptMethodInvoke.expectedFulfillmentCount = 2
        let adapter = MockAdapter(httpHeaders: [:]) {
            adaptMethodInvoke.fulfill()
        }

        /// Response validator
        var validationResult: Result<Void, NetworkError>!
        let validationInvoked = expectation(description: "Validation method invoked")
        validationInvoked.expectedFulfillmentCount = 2
        let validator = MockDataResponseValidator {
            validationInvoked.fulfill()
            return validationResult
        }

        /// Construct provider with interceptor & validator
        let provider = NetworkProvider<MockLoginEndpoints>(
            session: mockSession!,
            requestInterceptor: .init(adapters: [adapter]),
            dataResponseValidator: validator
        )

        let requestReceivedExp = expectation(description: "Network request received")
        requestReceivedExp.expectedFulfillmentCount = 2
        let mockUserData = """
        {
            "id": "123",
            "name": "Xyz",
            "age": 18
        }
        """.data(using: .utf8)!
        URLProtocolMock.onStartLoading = {
            let response = HTTPURLResponse(
                url: MockLoginEndpoints.url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            requestReceivedExp.fulfill()
            return (response, mockUserData)
        }

        /// Execute post request
        validationResult = .success(())
        let responseData = try await provider.perform(target: .getUser(userId: "123"), response: MockUserObject.self)
        let user = responseData.response
        XCTAssertEqual(user.id, "123")
        XCTAssertEqual(user.name, "Xyz")
        XCTAssertEqual(user.age, 18)

        /// Execute post request with validation failure
        let validationErrorExp = expectation(description: "Expecting validation error")
        do {
            validationResult = .failure(.responseValidationFailed(error: .none))
            _ = try await provider.perform(target: .getUser(userId: "123"), response: MockUserObject.self)
            XCTFail("Perform method should throws an error for validation result: \(String(describing: validationResult))")
        } catch {
            validationErrorExp.fulfill()
        }
        let exceptions = [adaptMethodInvoke, requestReceivedExp, validationInvoked, validationErrorExp]
        await fulfillment(of: exceptions, timeout: 3)
    }
}
