public struct CachedResponse {
    private let cachedResponse: NSCachedURLResponse
    private let duration: NSTimeInterval

    public init (response: NSURLResponse,
                 data: NSData,
                 duration: NSTimeInterval,
                 creationDate: NSDate = NSDate(),
                 storagePolicy: NSURLCacheStoragePolicy = .Allowed) {
        cachedResponse = NSCachedURLResponse(response: response,
                                             data: data,
                                             userInfo: ["creation_date": creationDate],
                                             storagePolicy: storagePolicy)
        self.duration = duration
    }

    public init (cachedResponse: NSCachedURLResponse,
                 duration: NSTimeInterval) {
        self.cachedResponse = cachedResponse
        self.duration = duration
    }

    public var isExpired: Bool {
        guard let creationDate = self.creationDate else {
            return true
        }
        return creationDate.timeIntervalSinceNow > duration
    }

    private var creationDate: NSDate? {
        return cachedResponse.userInfo?["creation_date"] as? NSDate
    }

    public var response: NSURLResponse {
        return cachedResponse.response
    }

    public var data: NSData {
        return cachedResponse.data
    }

    public func store(for request: NSURLRequest, cache: URLCache) {
        cache.storeCachedResponse(cachedResponse, forRequest: request)
    }
}

public protocol URLCache {
    func cachedResponseForRequest(request: NSURLRequest) -> NSCachedURLResponse?
    func storeCachedResponse(cachedResponse: NSCachedURLResponse, forRequest request: NSURLRequest)
}

extension NSURLCache: URLCache {}
