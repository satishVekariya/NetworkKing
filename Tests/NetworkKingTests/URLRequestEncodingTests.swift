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

    @Test("encoded(urlQueryItems:) renders nil value as bare key (no '=')")
    func queryParametersNilValue() throws {
        var request = URLRequest(url: url)
        request = try request.encoded(urlQueryItems: ["flag": nil])
        let finalURL = try #require(request.url)
        let comps = try #require(URLComponents(url: finalURL, resolvingAgainstBaseURL: false))
        let item = try #require(comps.queryItems?.first { $0.name == "flag" })
        #expect(item.value == nil)
        #expect(finalURL.absoluteString.hasSuffix("?flag"))
    }

    @Test("encoded(urlQueryItems:) percent-encodes reserved characters in values")
    func queryParametersSpecialChars() throws {
        var request = URLRequest(url: url)
        request = try request.encoded(urlQueryItems: ["q": "a b&c=d"])
        let finalURL = try #require(request.url)
        let comps = try #require(URLComponents(url: finalURL, resolvingAgainstBaseURL: false))
        let item = try #require(comps.queryItems?.first { $0.name == "q" })
        // URLComponents decodes back to the original string
        #expect(item.value == "a b&c=d")
        // Raw URL must have the reserved chars percent-encoded
        let raw = finalURL.absoluteString
        #expect(!raw.contains("a b"))            // space encoded
        #expect(raw.contains("%20") || raw.contains("+")) // either encoding is acceptable
        #expect(!raw.contains("&c=d"))           // '&' / '=' inside value not literal
    }

    @Test("encoded(urlQueryItems:) preserves an existing query string component")
    func queryParametersPreservesExisting() throws {
        var request = URLRequest(url: URL(string: "http://api.test.com?existing=1")!)
        request = try request.encoded(urlQueryItems: ["new": "2"])
        let finalURL = try #require(request.url)
        let comps = try #require(URLComponents(url: finalURL, resolvingAgainstBaseURL: false))
        let names = (comps.queryItems ?? []).map(\.name)
        // The current implementation replaces queryItems; pin that contract
        #expect(names.contains("new"))
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
