import Foundation
import Testing
@testable import NetworkKing

@Suite("NetworkTargetType defaults & URL composition")
struct TargetTypeDefaultsTests {

    private enum MinimalTarget: NetworkTargetType {
        case ping
        var baseURL: URL { URL(string: "https://api.example.com")! }
        var path: String { "/ping" }
        var method: HTTPMethod { .get }
    }

    @Test("Default headers is nil")
    func defaultHeaders() {
        #expect(MinimalTarget.ping.headers == nil)
    }

    @Test("Default task is .requestPlain")
    func defaultTask() {
        if case .requestPlain = MinimalTarget.ping.task { return }
        Issue.record("expected .requestPlain")
    }

    @Test("toURLRequest composes baseURL + path")
    func urlComposition() throws {
        let request = try MinimalTarget.ping.toURLRequest()
        #expect(request.url?.absoluteString == "https://api.example.com/ping")
        #expect(request.httpMethod == "GET")
    }

    @Test("toURLRequest applies custom headers")
    func customHeaders() throws {
        struct CustomTarget: NetworkTargetType {
            var baseURL: URL { URL(string: "https://x.com")! }
            var path: String { "/y" }
            var method: HTTPMethod { .get }
            var headers: [String: String]? { ["X-Trace": "abc"] }
        }
        let request = try CustomTarget().toURLRequest()
        #expect(request.value(forHTTPHeaderField: "X-Trace") == "abc")
    }

    @Test("toURLRequest with .requestData sets httpBody")
    func dataBody() throws {
        struct RawTarget: NetworkTargetType {
            let payload: Data
            var baseURL: URL { URL(string: "https://x.com")! }
            var path: String { "/r" }
            var method: HTTPMethod { .post }
            var task: RequestTask { .requestData(payload) }
        }
        let payload = Data([0x01, 0x02, 0x03])
        let request = try RawTarget(payload: payload).toURLRequest()
        #expect(request.httpBody == payload)
    }

    @Test("toURLRequest with .requestJSONEncodable encodes body")
    func jsonEncodableBody() throws {
        struct Body: Codable, Equatable { let id: Int }
        struct JSONTarget: NetworkTargetType {
            let body: Body
            var baseURL: URL { URL(string: "https://x.com")! }
            var path: String { "/j" }
            var method: HTTPMethod { .post }
            var task: RequestTask { .requestJSONEncodable(body) }
        }
        let body = Body(id: 7)
        let request = try JSONTarget(body: body).toURLRequest()
        let raw = try #require(request.httpBody)
        let decoded = try JSONDecoder().decode(Body.self, from: raw)
        #expect(decoded == body)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test("urlRequest convenience returns the same URLRequest as toURLRequest()")
    func urlRequestConvenienceMatches() throws {
        let direct = try MinimalTarget.ping.toURLRequest()
        let convenience = try #require(MinimalTarget.ping.urlRequest)
        #expect(convenience == direct)
    }

    @Test("toURLRequest with .requestURLQueryParameters appends query")
    func queryParameters() throws {
        struct QueryTarget: NetworkTargetType {
            var baseURL: URL { URL(string: "https://x.com")! }
            var path: String { "/q" }
            var method: HTTPMethod { .get }
            var task: RequestTask { .requestURLQueryParameters(["a": "1"]) }
        }
        let request = try QueryTarget().toURLRequest()
        let s = try #require(request.url?.absoluteString)
        #expect(s.contains("a=1"))
    }
}
