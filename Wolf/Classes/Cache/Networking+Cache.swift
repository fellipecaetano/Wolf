import Alamofire

public extension HTTPClient {
    func sendRequest<R: protocol<HTTPResource, CacheableResource>>
        (resource: R, completionHandler: Response<R.Value, R.Error> -> Void) -> Request {

        let requestToSend = request(resource)
        let cachedResponse = CachedResponse(request: requestToSend, resource: resource)

        if let cachedResponse = cachedResponse where !cachedResponse.isExpired {
            let result = resource.responseSerializer.serializeResponse(requestToSend.request,
                                                                       cachedResponse.response as? NSHTTPURLResponse,
                                                                       cachedResponse.data,
                                                                       nil)
            let response = Response(request: requestToSend.request,
                                    response: cachedResponse.response as? NSHTTPURLResponse,
                                    data: cachedResponse.data,
                                    result: result)
            completionHandler(response)
            return requestToSend
        } else {
            return requestToSend
                .validate()
                .response(responseSerializer: resource.responseSerializer,
                          completionHandler: cache(resource, completionHandler))
        }
    }

    func sendArrayRequest<R: protocol<HTTPResource, CacheableResource>>
        (resource: R, completionHandler: Response<[R.Value], R.Error> -> Void) -> Request {

        let requestToSend = request(resource)
        let cachedResponse = CachedResponse(request: requestToSend, resource: resource)

        if let cachedResponse = cachedResponse where !cachedResponse.isExpired {
            let result = resource.arrayResponseSerializer.serializeResponse(requestToSend.request,
                                                                            cachedResponse.response as? NSHTTPURLResponse,
                                                                            cachedResponse.data,
                                                                            nil)
            let response = Response(request: requestToSend.request,
                                    response: cachedResponse.response as? NSHTTPURLResponse,
                                    data: cachedResponse.data,
                                    result: result)
            completionHandler(response)
            return requestToSend
        } else {
            return request(resource)
                .validate()
                .response(responseSerializer: resource.arrayResponseSerializer,
                          completionHandler: cache(resource, completionHandler))
        }
    }
}

private extension CachedResponse {
    init? <R: protocol<HTTPResource, CacheableResource>> (request: Request, resource: R) {
        if let request = request.request, response = resource.cache.cachedResponseForRequest(request) {
            self.init(cachedResponse: response, duration: resource.cacheDuration)
        } else {
            return nil
        }
    }
}

private func cache<R: protocol<HTTPResource, CacheableResource>, V, E: ErrorType>
    (resource: R, _ completionHandler: Response<V, E> -> Void) -> Response<V, E> -> Void {

    return { response in
        if let request = response.request, httpResponse = response.response, data = response.data where response.result.error == nil {
            let cachedResponse = CachedResponse(response: httpResponse,
                                                data: data,
                                                duration: resource.cacheDuration,
                                                storagePolicy: resource.cacheStoragePolicy)
            cachedResponse.store(for: request, cache: resource.cache)
        }
        completionHandler(response)
    }
}

public protocol CacheableResource {
    var cache: URLCache { get }
    var cacheDuration: NSTimeInterval { get }
    var cacheStoragePolicy: NSURLCacheStoragePolicy { get }
}
