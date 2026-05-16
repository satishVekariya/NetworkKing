import Foundation
import Testing
@testable import NetworkKing

@Suite("Error → NetworkError mapping")
struct ErrorMappingTests {

    @Test("Existing NetworkError values pass through unchanged", arguments: [
        NetworkError.decodingFailed(error: NSError(domain: "t", code: 1)),
        NetworkError.encodingFailed(error: NSError(domain: "t", code: 1)),
        NetworkError.urlEncodingFailed(reason: "missing url"),
        NetworkError.responseValidationFailed(error: NSError(domain: "t", code: 1)),
    ])
    func passthrough(_ error: NetworkError) {
        let mapped = (error as Error).toNetworkError()
        if case .underlaying = mapped {
            Issue.record("\(error) should not be mapped to .underlaying")
        }
    }

    @Test("Non-NetworkError, non-DecodingError wraps as .underlaying")
    func underlayingWrap() {
        let mapped = NSError(domain: "test", code: 42).toNetworkError()
        guard case .underlaying = mapped else {
            Issue.record("expected .underlaying, got \(mapped)")
            return
        }
    }

    @Test("DecodingError variants map to .decodingFailed", arguments: decodingErrorCases())
    func decodingErrorsMap(_ error: DecodingError) {
        let mapped = (error as Error).toNetworkError()
        guard case .decodingFailed = mapped else {
            Issue.record("expected .decodingFailed, got \(mapped)")
            return
        }
    }

    @Test("LocalizedError descriptions are non-empty for every case")
    func localizedDescriptions() throws {
        let cases: [NetworkError] = [
            .decodingFailed(error: NSError(domain: "t", code: 1)),
            .encodingFailed(error: NSError(domain: "t", code: 1)),
            .urlEncodingFailed(reason: "bad"),
            .underlaying(error: NSError(domain: "t", code: 1)),
            .responseValidationFailed(error: nil),
            .responseValidationFailed(error: NSError(domain: "t", code: 1)),
        ]
        for c in cases {
            let desc = try #require(c.errorDescription)
            #expect(!desc.isEmpty)
        }
    }
}

private func decodingErrorCases() -> [DecodingError] {
    enum DummyKey: CodingKey { case none }
    let ctx = DecodingError.Context(codingPath: [], debugDescription: "")
    return [
        .dataCorrupted(ctx),
        .typeMismatch(Void.self, ctx),
        .valueNotFound(Void.self, ctx),
        .keyNotFound(DummyKey.none, ctx),
    ]
}
