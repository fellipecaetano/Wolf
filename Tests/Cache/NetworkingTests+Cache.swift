import XCTest
import Nimble
import Wolf
import Alamofire
import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif

class CacheNetworkingTests: XCTestCase {
    private let client = TestClient()

    func testThatObjectRequestsAreCached() {
        _ = stub(condition: isPath("/get/song")) { _ in
            return fixture(filePath: GetPathForFile("song.json", type(of: self)), headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableResource.getCachedSong(cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let cachedResponse = cache.cachedResponse(for: response.request!)
                expect(cachedResponse?.storagePolicy) == .allowedInMemoryOnly
                done()
            }
        }
    }

    func testThatCacheableResourcesValidateRequests() {
        _ = stub(condition: isPath("/get/song")) { _ in
            return fixture(filePath: GetPathForFile("song.json", type(of: self)), headers: nil)
        }

        let cache = TestURLCache()
        let expected = NSError(domain: "WolfTestErrorDomain", code: 666, userInfo: nil)
        let resource = Song.CacheableResource.getValidatedSong(cache: cache, error: expected)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let actual = response.result.error as NSError?
                expect(actual?.domain) == expected.domain
                expect(actual?.code) == expected.code
                done()
            }
        }
    }

    func testThatArrayRequestsAreCached() {
        _ = stub(condition: isPath("/get/songs")) { _ in
            return fixture(filePath: GetPathForFile("songs.json", type(of: self)), headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableArrayResource.getCachedSongs(cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let cachedResponse = cache.cachedResponse(for: response.request!)
                expect(cachedResponse?.storagePolicy) == .allowedInMemoryOnly
                done()
            }
        }
    }

    func testThatFailedObjectRequestsAreNotCached() {
        _ = stub(condition: isPath("/get/song")) { _ in
            #if SWIFT_PACKAGE
            return HTTPStubsResponse(data: Data() as Data, statusCode: 500, headers: nil)
            #else
            return OHHTTPStubsResponse(data: Data() as Data, statusCode: 500, headers: nil)
            #endif
        }

        let cache = TestURLCache()
        let resource = Song.CacheableResource.getCachedSong(cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let cachedResponse = cache.cachedResponse(for: response.request!)
                expect(cachedResponse).to(beNil())
                done()
            }
        }
    }

    func testThatFailedArrayRequestsAreNotCached() {
        _ = stub(condition: isPath("/get/songs")) { _ in
            return fixture(filePath: GetPathForFile("invalid_json.json", type(of: self)), headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableArrayResource.getCachedSongs(cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                let cachedResponse = cache.cachedResponse(for: response.request!)
                expect(cachedResponse).to(beNil())
                done()
            }
        }
    }

    func testThatNonExpiredCachedObjectRequestsAreReturned() {
        _ = stub(condition: isPath("/get/song")) { _ in
            return fixture(filePath: GetPathForFile("invalid_json.json", type(of: self)), headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableResource.getCachedSong(cache: cache)
        let validJSON = try? Data(contentsOf: systemPath("song", extension: "json")!)
        let cachedResponse = CachedResponse(response: URLResponse(), data: validJSON!, duration: 30)

        cachedResponse.store(for: client.request(resource).request!, cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                switch response.result {
                case .success(let value):
                    expect(value.title) == "Northern Lites"
                    done()
                case .failure:
                    fail("This request should not fail")
                    done()
                }
            }
        }
    }

    func testThatNonExpiredCachedArrayRequestsAreReturned() {
        _ = stub(condition: isPath("/get/songs")) { _ in
            return fixture(filePath: GetPathForFile("invalid_user.json", type(of: self)), headers: nil)
        }

        let validJSON = try? Data(contentsOf: systemPath("songs", extension: "json")!)
        let cachedResponse = CachedResponse(response: URLResponse(), data: validJSON!, duration: 30)
        let cache = TestURLCache()
        let resource = Song.CacheableArrayResource.getCachedSongs(cache: cache)

        cachedResponse.store(for: client.request(resource).request!, cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                switch response.result {
                case .success(let value):
                    expect(value.count) == 4
                    done()
                case .failure:
                    fail("This request should not fail")
                    done()
                }
            }
        }
    }

    func testThatExpiredCachedObjectRequestsAreSkipped() {
        _ = stub(condition: isPath("/get/song")) { _ in
            return fixture(filePath: GetPathForFile("invalid_json.json", type(of: self)), headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableResource.getCachedSong(cache: cache)
        let validJSON = try? Data(contentsOf: systemPath("songs", extension: "json")!)
        let cachedResponse = CachedResponse(response: URLResponse(),
                                            data: validJSON!,
                                            duration: resource.cacheDuration,
                                            creationDate: Date(timeIntervalSinceNow: resource.cacheDuration + 1))

        cachedResponse.store(for: client.request(resource).request!, cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                switch response.result {
                case .success:
                    fail("This request should not succeed")
                    done()
                case .failure:
                    done()
                }
            }
        }
    }

    func testThatExpiredCachedArrayRequestsAreSkipped() {
        _ = stub(condition: isPath("/get/songs")) { _ in
            return fixture(filePath: GetPathForFile("invalid_user.json", type(of: self)), headers: nil)
        }

        let cache = TestURLCache()
        let resource = Song.CacheableArrayResource.getCachedSongs(cache: cache)
        let validJSON = try? Data(contentsOf: systemPath("songs", extension: "json")!)
        let cachedResponse = CachedResponse(response: URLResponse(),
                                            data: validJSON!,
                                            duration: resource.cacheDuration,
                                            creationDate: Date(timeIntervalSinceNow: resource.cacheDuration + 1))

        cachedResponse.store(for: client.request(resource).request!, cache: cache)

        waitUntil { done in
            self.client.sendRequest(resource) { response in
                switch response.result {
                case .success:
                    fail("This request should not succeed")
                    done()
                case .failure:
                    done()
                }
            }
        }
    }


    private func systemPath(_ resource: String, extension ext: String) -> URL? {
        #if SWIFT_PACKAGE
        return UrlForFile("\(resource).\(ext)")
        #else
        return Bundle(for: type(of: self)).url(forResource: resource, withExtension: ext)
        #endif
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

        case getCachedSong(cache: Wolf.URLCache)
        case getValidatedSong(cache: Wolf.URLCache, error: Error)

        var path: String {
            switch self {
            case .getCachedSong, .getValidatedSong:
                return "get/song"
            }
        }

        var cache: Wolf.URLCache {
            switch self {
            case .getCachedSong(let cache):
                return cache
            case let .getValidatedSong(cache, _):
                return cache
            }
        }

        var cacheStoragePolicy: Foundation.URLCache.StoragePolicy {
            return CacheConfiguration().cacheStoragePolicy
        }

        var cacheDuration: TimeInterval {
            return CacheConfiguration().cacheDuration
        }

        fileprivate func validate(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
            switch self {
            case let .getValidatedSong(_, error):
                return .failure(error)
            default:
                return .success
            }
        }
    }

    enum CacheableArrayResource: HTTPResource, Wolf.CacheableResource {
        typealias Value = [Song]

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

    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        cachedResponses[request.url!] = cachedResponse
    }

    func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return cachedResponses[request.url!]
    }
}
