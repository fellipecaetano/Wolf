import XCTest
import Nimble
import Wolf

class CachedResponseTests: XCTestCase {
    func testExpirationWhenNotExpired() {
        let cachedResponse = CachedResponse(response: URLResponse(),
                                            data: Data(),
                                            duration: 30)
        expect(cachedResponse.isExpired) == false
    }

    func testExpirationWhenExpired() {
        let cachedResponse = CachedResponse(response: URLResponse(),
                                            data: Data(),
                                            duration: 30,
                                            creationDate: Date(timeIntervalSinceNow: 31))
        expect(cachedResponse.isExpired) == true
    }

    func testStorage() {
        let request = URLRequest(url: URL(string: "http://example.com/request")!)
        let response = URLResponse(url: URL(string: "http://example.com/response")!,
                                   mimeType: nil,
                                   expectedContentLength: 0,
                                   textEncodingName: nil)

        let underlyingCachedResponse = CachedURLResponse(response: response, data: Data())
        let cachedResponse = CachedResponse(cachedResponse: underlyingCachedResponse,
                                            duration: 30)
        let cache = URLCache()
        cachedResponse.store(for: request, cache: cache)

        let storedResponse = cache.cachedResponse(for: request)
        expect(storedResponse?.response.url) == response.url
    }
}
