import Alamofire

public extension HTTPClient {
    func sendRequest<R: HTTPResource & CacheableResource>
        (_ resource: R, completionHandler: (Response<R.Value, R.Error>) -> Void) -> Request {

        return request(resource)
            .validate()
            .cachedResponse(resource,
                            responseSerializer: resource.responseSerializer,
                            completionHandler: cache(resource, completionHandler))
    }
}

public protocol CacheableResource {
    var cache: URLCache { get }
    var cacheDuration: TimeInterval { get }
    var cacheStoragePolicy: Foundation.URLCache.StoragePolicy { get }
}

public extension CacheableResource {
    var cache: URLCache {
        return Foundation.URLCache.shared as! URLCache
    }

    var cacheStoragePolicy: Foundation.URLCache.StoragePolicy {
        return .allowed
    }
}

private extension Request {
    func cachedResponse<C: CacheableResource, S: ResponseSerializerType>
        (_ resource: C, responseSerializer: S, completionHandler: (Response<S.SerializedObject, S.ErrorObject>) -> Void) -> Self {

        if let cachedResponse = CachedResponse(request: self, resource: resource), !cachedResponse.isExpired {
            let response: Response = responseSerializer.serializeResponse(request,
                                                                          cachedResponse.response as? NSHTTPURLResponse,
                                                                          cachedResponse.data,
                                                                          nil)
            completionHandler(response)
            return self
        } else {
            return validate().response(responseSerializer: responseSerializer,
                                       completionHandler: completionHandler)
        }
    }
}

private extension CachedResponse {
    init? <R: CacheableResource> (request: Request, resource: R) {
        if let request = request.request, let response = resource.cache.cachedResponseForRequest(request) {
            self.init(cachedResponse: response, duration: resource.cacheDuration)
        } else {
            return nil
        }
    }
}

private func cache<R: CacheableResource, V, E: Error>
    (_ resource: R, _ completionHandler: (Response<V, E>) -> Void) -> (Response<V, E>) -> Void {

    return { response in
        if let request = response.request, let httpResponse = response.response, let data = response.data, response.result.error == nil {
            let cachedResponse = CachedResponse(response: httpResponse,
                                                data: data,
                                                duration: resource.cacheDuration,
                                                storagePolicy: resource.cacheStoragePolicy)
            cachedResponse.store(for: request, cache: resource.cache)
        }
        completionHandler(response)
    }
}

private extension ResponseSerializerType {
    func serializeResponse(_ request: NSURLRequest?,
                           _ response: NSHTTPURLResponse?,
                             _ data: NSData?,
                               _ error: NSError?) -> Response<SerializedObject, ErrorObject> {
        let result = serializeResponse(request, response, data, error)
        return Response(request: request, response: response, data: data, result: result)
    }
}
