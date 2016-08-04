import Alamofire

public extension HTTPClient {
    func sendRequest<R: protocol<HTTPResource, CacheableResource>>
        (resource: R, completionHandler: Response<R.Value, R.Error> -> Void) -> Request {

        return request(resource)
            .validate()
            .response(responseSerializer: resource.responseSerializer) { response in
                if let request = response.request, httpResponse = response.response, data = response.data {
                    let cachedResponse = CachedResponse(response: httpResponse,
                                                        data: data,
                                                        duration: 30,
                                                        storagePolicy: resource.cacheStoragePolicy)
                    cachedResponse.store(for: request, cache: resource.cache)
                }
                completionHandler(response)
        }
    }

    func sendArrayRequest<R: protocol<HTTPResource, CacheableResource>>
        (resource: R, completionHandler: Response<[R.Value], R.Error> -> Void) -> Request {

        return request(resource)
            .validate()
            .response(responseSerializer: resource.arrayResponseSerializer) { response in
                if let request = response.request, httpResponse = response.response, data = response.data {
                    let cachedResponse = CachedResponse(response: httpResponse,
                                                        data: data,
                                                        duration: 30,
                                                        storagePolicy: resource.cacheStoragePolicy)
                    cachedResponse.store(for: request, cache: resource.cache)
                }
                completionHandler(response)
        }
    }
}

public protocol CacheableResource {
    var cache: NSURLCache { get }
    var cacheStoragePolicy: NSURLCacheStoragePolicy { get }
}
