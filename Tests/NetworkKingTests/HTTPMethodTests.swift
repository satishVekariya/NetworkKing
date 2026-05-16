import Testing
@testable import NetworkKing

@Suite("HTTPMethod")
struct HTTPMethodTests {

    @Test("Raw values match HTTP spec", arguments: [
        (HTTPMethod.get,    "GET"),
        (HTTPMethod.post,   "POST"),
        (HTTPMethod.put,    "PUT"),
        (HTTPMethod.delete, "DELETE"),
    ])
    func rawValues(_ method: HTTPMethod, _ expected: String) {
        #expect(method.rawValue == expected)
    }

    @Test("allCases exposes every method exactly once")
    func allCasesUnique() {
        let cases = HTTPMethod.allCases
        #expect(cases.count == 4)
        #expect(Set(cases).count == cases.count)
    }
}
