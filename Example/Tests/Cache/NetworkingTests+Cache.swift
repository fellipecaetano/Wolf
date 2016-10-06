import XCTest
import Nimble
import OHHTTPStubs
import Wolf

class CacheNetworkingTests: XCTestCase {
    private let client = TestClient()

    func testThatObjectRequestsAreCached() {
        _ = stub(condition: isPath("/get/song")) { _ in
            return fixture(filePath: OHPathForFile("song.json", type(of: self))!, headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableResource.getCachedSong(cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let cachedResponse = cache.cachedResponseForRequest(response.request!)
                expect(cachedResponse?.storagePolicy) == .allowedInMemoryOnly
                done()
            }
        }
    }

    func testThatArrayRequestsAreCached() {
        _ = stub(condition: isPath("/get/songs")) { _ in
            return fixture(filePath: OHPathForFile("songs.json", type(of: self))!, headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableArrayResource.getCachedSongs(cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let cachedResponse = cache.cachedResponseForRequest(response.request!)
                expect(cachedResponse?.storagePolicy) == .allowedInMemoryOnly
                done()
            }
        }
    }

    func testThatFailedObjectRequestsAreNotCached() {
        _ = stub(condition: isPath("/get/song")) { _ in
            return OHHTTPStubsResponse(data: Data() as Data, statusCode: 500, headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableResource.getCachedSong(cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let cachedResponse = cache.cachedResponseForRequest(response.request!)
                expect(cachedResponse).to(beNil())
                done()
            }
        }
    }

    func testThatFailedArrayRequestsAreNotCached() {
        _ = stub(condition: isPath("/get/songs")) { _ in
            return fixture(filePath: OHPathForFile("invalid_json.json", type(of: self))!, headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableArrayResource.getCachedSongs(cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let cachedResponse = cache.cachedResponseForRequest(response.request!)
                expect(cachedResponse).to(beNil())
                done()
            }
        }
    }

    func testThatNonExpiredCachedObjectRequestsAreReturned() {
        _ = stub(condition: isPath("/get/song")) { _ in
            return fixture(filePath: OHPathForFile("invalid_json.json", type(of: self))!, headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableResource.getCachedSong(cache: cache)
        let validJSON = try? Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "song", withExtension: "json")!)
        let cachedResponse = CachedResponse(response: URLResponse(), data: validJSON!, duration: 30)

        cachedResponse.store(for: client.request(resource).request!, cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource).onSuccess { value in
                expect(value.title  ) == "Northern Lites"
                done()
            }.onFailure { _ in
                fail("This request should not fail")
                done()
            }
        }
    }

    func testThatNonExpiredCachedArrayRequestsAreReturned() {
        _ = stub(condition: isPath("/get/songs")) { _ in
            return fixture(filePath: OHPathForFile("invalid_user.json", type(of: self))!, headers: nil)
        }

        let validJSON = try? Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "songs", withExtension: "json")!)
        let cachedResponse = CachedResponse(response: URLResponse(), data: validJSON!, duration: 30)
        let cache = TestURLCache()
        let resource = Song.CacheableArrayResource.getCachedSongs(cache: cache)

        cachedResponse.store(for: client.request(resource).request!, cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource).onSuccess { value in
                expect(value.count) == 4
                done()
            }.onFailure { _ in
                fail("This request should not fail")
                done()
            }
        }
    }

    func testThatExpiredCachedObjectRequestsAreSkipped() {
        _ = stub(condition: isPath("/get/song")) { _ in
            return fixture(filePath: OHPathForFile("invalid_json.json", type(of: self))!, headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableResource.getCachedSong(cache: cache)
        let validJSON = try? Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "songs", withExtension: "json")!)
        let cachedResponse = CachedResponse(response: URLResponse(),
                                            data: validJSON!,
                                            duration: resource.cacheDuration,
                                            creationDate: Date(timeIntervalSinceNow: resource.cacheDuration + 1))

        cachedResponse.store(for: client.request(resource).request!, cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource).onSuccess { _ in
                fail("This request should not succeed")
                done()
            }.onFailure { _ in
                done()
            }
        }
    }

    func testThatExpiredCachedArrayRequestsAreSkipped() {
        _ = stub(condition: isPath("/get/songs")) { _ in
            return fixture(filePath: OHPathForFile("invalid_user.json", type(of: self))!, headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableArrayResource.getCachedSongs(cache: cache)
        let validJSON = try? Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "songs", withExtension: "json")!)
        let cachedResponse = CachedResponse(response: URLResponse(),
                                            data: validJSON!,
                                            duration: resource.cacheDuration,
                                            creationDate: Date(timeIntervalSinceNow: resource.cacheDuration + 1))

        cachedResponse.store(for: client.request(resource).request!, cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource).onSuccess { _ in
                fail("This request should not succeed")
                done()
            }.onFailure { _ in
                done()
            }
        }
    }
}

private extension Song {
    struct CacheConfiguration {
        var cacheStoragePolicy: Foundation.URLCache.StoragePolicy {
            return .allowedInMemoryOnly
        }

        var cacheDuration: TimeInterval {
            return 15
        }
    }

    enum CacheableResource: HTTPResource, Wolf.CacheableResource {
        typealias Value = Song
        typealias Error = UnboxResponseError

        case getCachedSong(cache: Wolf.URLCache)

        var path: String {
            switch self {
            case .getCachedSong:
                return "get/song"
            }
        }

        var cache: Wolf.URLCache {
            switch self {
            case .getCachedSong(let cache):
                return cache
            }
        }

        var cacheStoragePolicy: Foundation.URLCache.StoragePolicy {
            return CacheConfiguration().cacheStoragePolicy
        }

        var cacheDuration: TimeInterval {
            return CacheConfiguration().cacheDuration
        }
    }

    enum CacheableArrayResource: HTTPResource, Wolf.CacheableResource {
        typealias Value = [Song]
        typealias Error = UnboxResponseError

        case getCachedSongs(cache: Wolf.URLCache)

        var path: String {
            switch self {
            case .getCachedSongs:
                return "get/songs"
            }
        }

        var cache: Wolf.URLCache {
            switch self {
            case .getCachedSongs(let cache):
                return cache
            }
        }

        var cacheStoragePolicy: Foundation.URLCache.StoragePolicy {
            return CacheConfiguration().cacheStoragePolicy
        }

        var cacheDuration: TimeInterval {
            return CacheConfiguration().cacheDuration
        }
    }
}

private class TestURLCache: Wolf.URLCache {
    var cachedResponses: [URL: CachedURLResponse] = [:]

    func storeCachedResponse(_ cachedResponse: CachedURLResponse, forRequest request: URLRequest) {
        cachedResponses[request.url!] = cachedResponse
    }

    fileprivate func cachedResponseForRequest(_ request: URLRequest) -> CachedURLResponse? {
        return cachedResponses[request.url!]
    }
}
