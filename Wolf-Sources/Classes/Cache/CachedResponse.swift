public struct CachedResponse {
    fileprivate let cachedResponse: CachedURLResponse
    fileprivate let duration: TimeInterval

    public init (response: URLResponse,
                 data: Data,
                 duration: TimeInterval,
                 creationDate: Date = Date(),
                 storagePolicy: Foundation.URLCache.StoragePolicy = .allowed) {
        cachedResponse = CachedURLResponse(response: response,
                                           data: data,
                                           userInfo: ["creation_date": creationDate],
                                           storagePolicy: storagePolicy)
        self.duration = duration
    }

    public init (cachedResponse: CachedURLResponse,
                 duration: TimeInterval) {
        self.cachedResponse = cachedResponse
        self.duration = duration
    }

    public var isExpired: Bool {
        guard let creationDate = self.creationDate else {
            return true
        }
        return creationDate.timeIntervalSinceNow > duration
    }

    fileprivate var creationDate: Date? {
        return cachedResponse.userInfo?["creation_date"] as? Date
    }

    public var response: URLResponse {
        return cachedResponse.response
    }

    public var data: Data {
        return cachedResponse.data
    }

    public func store(for request: URLRequest, cache: URLCache) {
        cache.storeCachedResponse(cachedResponse, forRequest: request)
    }
}

public protocol URLCache {
    func cachedResponseForRequest(_ request: URLRequest) -> CachedURLResponse?
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, forRequest request: URLRequest)
}

extension Foundation.URLCache: URLCache {}
