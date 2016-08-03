public struct CachedResponse {
    let cachedResponse: NSCachedURLResponse
    let duration: NSTimeInterval

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

    var creationDate: NSDate? {
        return cachedResponse.userInfo?["creation_date"] as? NSDate
    }

    public func store(for request: NSURLRequest,
                          cache: NSURLCache = NSURLCache.sharedURLCache()) {
        cache.storeCachedResponse(cachedResponse, forRequest: request)
    }
}
