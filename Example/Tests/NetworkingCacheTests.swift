import XCTest
import Nimble
import OHHTTPStubs
import Wolf

class CacheNetworkingTests: XCTestCase {
    private let client = ExampleClient()

    func testThatObjectRequestsAreCached() {
        stub(isPath("/get/user")) { _ in
            return fixture(OHPathForFile("user.json", self.dynamicType)!, headers: nil)
        }

        let cache = NSURLCache.memoryOnly()
        let resource = User.CacheableResource.getCachedUser(cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let cachedResponse = cache.cachedResponseForRequest(response.request!)
                expect(cachedResponse).toNot(beNil())
                expect(cachedResponse?.storagePolicy).to(equal(NSURLCacheStoragePolicy.AllowedInMemoryOnly))
                done()
            }
        }
    }

    func testThatArrayRequestsAreCached() {
        stub(isPath("/get/users")) { _ in
            return fixture(OHPathForFile("users.json", self.dynamicType)!, headers: nil)
        }

        let cache = NSURLCache.memoryOnly()
        let resource = User.CacheableResource.getCachedUsers(cache: cache)

        waitUntil { done in
            self.client.sendArrayRequest(resource) { response in
                let cachedResponse = cache.cachedResponseForRequest(response.request!)
                expect(cachedResponse).toNot(beNil())
                expect(cachedResponse?.storagePolicy).to(equal(NSURLCacheStoragePolicy.AllowedInMemoryOnly))
                done()
            }
        }
    }

    func testThatFailedObjectRequestsAreNotCached() {
        stub(isPath("/get/user")) { _ in
            return OHHTTPStubsResponse(data: NSData(), statusCode: 500, headers: nil)
        }

        let cache = NSURLCache.memoryOnly()
        let resource = User.CacheableResource.getCachedUser(cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let cachedResponse = cache.cachedResponseForRequest(response.request!)
                expect(cachedResponse).to(beNil())
                done()
            }
        }
    }

    func testThatFailedArrayRequestsAreNotCached() {
        stub(isPath("/get/users")) { _ in
            return fixture(OHPathForFile("invalid_json.json", self.dynamicType)!, headers: nil)
        }

        let cache = NSURLCache.memoryOnly()
        let resource = User.CacheableResource.getCachedUsers(cache: cache)

        waitUntil { done in
            self.client.sendArrayRequest(resource) { response in
                let cachedResponse = cache.cachedResponseForRequest(response.request!)
                expect(cachedResponse).to(beNil())
                done()
            }
        }
    }
}

private extension User {
    enum CacheableResource: HTTPResource, Wolf.CacheableResource {
        typealias Value = User
        typealias Error = ArgoResponseError

        case getCachedUser(cache: NSURLCache)
        case getCachedUsers(cache: NSURLCache)

        var path: String {
            switch self {
            case .getCachedUser:
                return "get/user"
            case .getCachedUsers:
                return "get/users"
            }
        }

        var cache: NSURLCache {
            switch self {
            case .getCachedUser(let cache):
                return cache
            case .getCachedUsers(let cache):
                return cache
            }
        }

        var cacheStoragePolicy: NSURLCacheStoragePolicy {
            return .AllowedInMemoryOnly
        }
    }
}

private extension NSURLCache {
    static func memoryOnly() -> NSURLCache {
        return NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 0, diskPath: nil)
    }
}
