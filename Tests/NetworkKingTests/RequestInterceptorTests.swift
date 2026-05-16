import Foundation
import Testing
@testable import NetworkKing

@Suite("RequestInterceptor")
struct RequestInterceptorTests {

    @Test("Single adapter mutates request")
    func singleAdapter() async throws {
        let count = TestBox(0)
        let adapter = MockAdapter(httpHeaders: ["Content-Type": "XYZ"]) { count.value += 1 }
        let interceptor = RequestInterceptor(adapters: [adapter])

        let target = MockTargetType.example1
        let request = try target.toURLRequest()
        let adapted = try await interceptor.adapt(request, for: target)

        #expect(count.value == 1)
        #expect(adapted.value(forHTTPHeaderField: "Content-Type") == "XYZ")
    }

    @Test("Adapters run in order; later overrides earlier")
    func adapterChainOrder() async throws {
        let calls = TestBox<[Int]>([])
        let a1 = MockAdapter(httpHeaders: ["X-K": "first"])  { calls.value.append(1) }
        let a2 = MockAdapter(httpHeaders: ["X-K": "second"]) { calls.value.append(2) }
        let interceptor = RequestInterceptor(adapters: [a1, a2])

        let target = MockTargetType.example1
        let request = try target.toURLRequest()
        let adapted = try await interceptor.adapt(request, for: target)

        #expect(calls.value == [1, 2])
        #expect(adapted.value(forHTTPHeaderField: "X-K") == "second")
    }

    @Test("Empty adapter list returns request unchanged")
    func emptyAdapters() async throws {
        let interceptor = RequestInterceptor()
        let request = URLRequest(url: URL(string: "https://x.com")!)
        let adapted = try await interceptor.adapt(request, for: MockTargetType.example1)
        #expect(adapted == request)
    }

    @Test("retry returns .retry when retrier signals retry")
    func retryReturnsRetry() async throws {
        let retrier = MockRequestRetrier { _, _, _ in .retry }
        let interceptor = RequestInterceptor(retriers: [retrier])
        let request = URLRequest(url: URL(string: "https://x.com")!)
        let result = try await interceptor.retry(request, for: MockTargetType.example1, dueTo: NSError(domain: "t", code: 1))
        #expect(result == .retry)
    }

    @Test("retry returns .doNotRetry when retrier signals so")
    func retryReturnsDoNotRetry() async throws {
        let retrier = MockRequestRetrier { _, _, _ in .doNotRetry }
        let interceptor = RequestInterceptor(retriers: [retrier])
        let request = URLRequest(url: URL(string: "https://x.com")!)
        let result = try await interceptor.retry(request, for: MockTargetType.example1, dueTo: NSError(domain: "t", code: 1))
        #expect(result == .doNotRetry)
    }

    @Test("retry stops at the first .doNotRetry in the chain")
    func retryChainStopsOnDoNotRetry() async throws {
        let calls = TestBox(0)
        let r1 = MockRequestRetrier { _, _, _ in calls.value += 1; return .doNotRetry }
        let r2 = MockRequestRetrier { _, _, _ in calls.value += 1; return .retry }
        let interceptor = RequestInterceptor(retriers: [r1, r2])
        let result = try await interceptor.retry(
            URLRequest(url: URL(string: "https://x.com")!),
            for: MockTargetType.example1,
            dueTo: NSError(domain: "t", code: 1)
        )
        #expect(calls.value == 1)
        #expect(result == .doNotRetry)
    }

    @Test("retry is forwarded the original request, target and error")
    func retryForwardsArguments() async throws {
        let originalRequest = URLRequest(url: URL(string: "http://t.com/abc")!)
        let originalTarget = MockTargetType.example1
        let originalError = NSError(domain: "test", code: 11)
        let captured = TestBox<(URLRequest?, NetworkTargetType?, Error?)>((nil, nil, nil))

        let retrier = MockRequestRetrier { req, target, error in
            captured.value = (req, target, error)
            return .doNotRetry
        }
        let interceptor = RequestInterceptor(retriers: [retrier])
        _ = try await interceptor.retry(originalRequest, for: originalTarget, dueTo: originalError)

        #expect(captured.value.0 == originalRequest)
        #expect((captured.value.1 as? MockTargetType) == originalTarget)
        #expect((captured.value.2 as NSError?) == originalError)
    }
}
