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

    @Test("LocalizedError descriptions surface the underlying error / reason")
    func localizedDescriptionsIncludeUnderlying() throws {
        let underlying = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "needle-42"])

        let decodingDesc = try #require(NetworkError.decodingFailed(error: underlying).errorDescription)
        #expect(decodingDesc.contains("needle-42"))

        let encodingDesc = try #require(NetworkError.encodingFailed(error: underlying).errorDescription)
        #expect(encodingDesc.contains("needle-42"))

        let urlEncodingDesc = try #require(NetworkError.urlEncodingFailed(reason: "needle-43").errorDescription)
        #expect(urlEncodingDesc.contains("needle-43"))

        let validationDesc = try #require(NetworkError.responseValidationFailed(error: underlying).errorDescription)
        #expect(validationDesc.contains("needle-42"))

        let nilValidationDesc = try #require(NetworkError.responseValidationFailed(error: nil).errorDescription)
        #expect(!nilValidationDesc.isEmpty)

        let underlayingDesc = try #require(NetworkError.underlaying(error: underlying).errorDescription)
        #expect(underlayingDesc.contains("needle-42"))
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
