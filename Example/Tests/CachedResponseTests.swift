import XCTest
import Nimble
import Wolf

class CachedResponseTests: XCTestCase {
    func testExpirationWhenNotExpired() {
        let cachedResponse = CachedResponse(response: NSURLResponse(),
                                            data: NSData(),
                                            duration: 30)
        expect(cachedResponse.isExpired).to(beFalse())
    }

    func testExpirationWhenExpired() {
        let cachedResponse = CachedResponse(response: NSURLResponse(),
                                            data: NSData(),
                                            duration: 30,
                                            creationDate: NSDate(timeIntervalSinceNow: 31))
        expect(cachedResponse.isExpired).to(beTrue())
    }

    func testStorage() {
        let request = NSURLRequest(URL: NSURL(string: "http://example.com/request")!)
        let response = NSURLResponse(URL: NSURL(string: "http://example.com/response")!,
                                     MIMEType: nil,
                                     expectedContentLength: 0,
                                     textEncodingName: nil)
        let underlyingCachedResponse = NSCachedURLResponse(response: response, data: NSData())
        let cachedResponse = CachedResponse(cachedResponse: underlyingCachedResponse,
                                            duration: 30)
        let cache = NSURLCache()
        cachedResponse.store(for: request, cache: cache)

        let storedResponse = cache.cachedResponseForRequest(request)
        expect(storedResponse).toNot(beNil())
        expect(storedResponse?.response.URL).to(equal(response.URL))
    }
}
