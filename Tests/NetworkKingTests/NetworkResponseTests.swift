import Foundation
import Testing
@testable import NetworkKing

@Suite("NetworkResponse")
struct NetworkResponseTests {

    @Test("Stores response, urlResponse and originalRequest verbatim")
    func storesFields() {
        struct Body: Decodable, Equatable { let v: Int }
        let body = Body(v: 42)
        let urlResponse = HTTPURLResponse(
            url: URL(string: "https://x.com")!,
            statusCode: 201,
            httpVersion: nil,
            headerFields: ["X-K": "V"]
        )!
        let request = URLRequest(url: URL(string: "https://x.com/r")!)
        let wrapped = NetworkResponse(response: body, urlResponse: urlResponse, originalRequest: request)
        #expect(wrapped.response == body)
        #expect((wrapped.urlResponse as? HTTPURLResponse)?.statusCode == 201)
        #expect(wrapped.originalRequest == request)
    }
}
