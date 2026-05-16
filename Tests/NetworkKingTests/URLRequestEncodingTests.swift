import Foundation
import Testing
@testable import NetworkKing

@Suite("URLRequest encoding extensions")
struct URLRequestEncodingTests {
    private let url = URL(string: "http://api.test.com")!

    @Test("Init with URL/method/headers sets all fields", arguments: HTTPMethod.allCases)
    func customInit(method: HTTPMethod) throws {
        let headers = ["Content-Type": "xyz", "X-Trace": "abc"]
        let request = try URLRequest(url: url, method: method, headers: headers)
        #expect(request.url == url)
        #expect(request.httpMethod == method.rawValue)
        #expect(request.allHTTPHeaderFields == headers)
    }

    @Test("Init with nil headers leaves headers nil")
    func customInitNilHeaders() throws {
        let request = try URLRequest(url: url, method: .get, headers: nil)
        #expect(request.allHTTPHeaderFields == nil || request.allHTTPHeaderFields?.isEmpty == true)
    }

    @Test("encoded(encodable:) sets JSON body and Content-Type")
    func encodableBody() throws {
        struct Payload: Codable, Equatable {
            let s: String; let i: Int; let b: Bool; let d: Double
        }
        let payload = Payload(s: "v", i: 1, b: true, d: 2.5)
        var request = URLRequest(url: url)
        request = try request.encoded(encodable: payload)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        let body = try #require(request.httpBody)
        let decoded = try JSONDecoder().decode(Payload.self, from: body)
        #expect(decoded == payload)
    }

    @Test("encoded(encodable:) preserves caller-provided Content-Type")
    func encodableBodyPreservesContentType() throws {
        var request = URLRequest(url: url)
        request.setValue("application/vnd.custom+json", forHTTPHeaderField: "Content-Type")
        request = try request.encoded(encodable: ["a": 1])
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/vnd.custom+json")
    }

    @Test("encoded(encodable:) throws .encodingFailed when encoder fails")
    func encodableEncodingFailure() {
        struct Bomb: Encodable {
            func encode(to encoder: Encoder) throws {
                throw NSError(domain: "encode", code: 1)
            }
        }
        var request = URLRequest(url: url)
        #expect(throws: NetworkError.self) {
            request = try request.encoded(encodable: Bomb())
        }
    }

    @Test("encoded(urlQueryItems:) appends all keys")
    func queryParameters() throws {
        var request = URLRequest(url: url)
        request = try request.encoded(urlQueryItems: ["q1": "val1", "q2": "val2"])
        let finalURL = try #require(request.url)
        let comps = try #require(URLComponents(url: finalURL, resolvingAgainstBaseURL: false))
        let items = comps.queryItems ?? []
        let dict = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value) })
        #expect(dict["q1"] == "val1")
        #expect(dict["q2"] == "val2")
    }

    @Test("encoded(urlQueryItems:) supports nil values")
    func queryParametersNilValue() throws {
        var request = URLRequest(url: url)
        request = try request.encoded(urlQueryItems: ["flag": nil])
        let finalURL = try #require(request.url)
        #expect(finalURL.absoluteString.contains("flag"))
    }

    @Test("encoded(urlQueryItems:) throws .urlEncodingFailed when url is nil")
    func queryParametersMissingURL() {
        var request = URLRequest(url: url)
        request.url = nil
        #expect(throws: NetworkError.self) {
            request = try request.encoded(urlQueryItems: ["a": "b"])
        }
    }

    @Test("setContentTypeApplicationJsonHeaderIfNeeded sets when missing")
    func setContentTypeIfMissing() {
        var request = URLRequest(url: url)
        request.setContentTypeApplicationJsonHeaderIfNeeded()
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test("setContentTypeApplicationJsonHeaderIfNeeded leaves existing value")
    func setContentTypePreserveExisting() {
        var request = URLRequest(url: url)
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.setContentTypeApplicationJsonHeaderIfNeeded()
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "text/plain")
    }
}
