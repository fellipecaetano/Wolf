import Alamofire
import Foundation

public extension HTTPClient {
    @discardableResult
    func sendRequest<R: HTTPResource & CacheableResource>
        (_ resource: R, completionHandler: @escaping (DataResponse<R.Value>) -> Void) -> DataRequest {

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
        return Foundation.URLCache.shared
    }

    var cacheStoragePolicy: Foundation.URLCache.StoragePolicy {
        return .allowed
    }
}

private extension DataRequest {
    func cachedResponse<C: CacheableResource, S: DataResponseSerializerProtocol>
        (_ resource: C, responseSerializer: S, completionHandler: @escaping (DataResponse<S.SerializedObject>) -> Void) -> Self {

        if let cachedResponse = CachedResponse(request: self, resource: resource), !cachedResponse.isExpired {
            let response: DataResponse = responseSerializer.serializeResponse(request,
                                                                              cachedResponse.response as? HTTPURLResponse,
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

private func cache<R: CacheableResource, V>
    (_ resource: R, _ completionHandler: @escaping (DataResponse<V>) -> Void) -> (DataResponse<V>) -> Void {

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

private extension DataResponseSerializerProtocol {
    func serializeResponse(_ request: URLRequest?,
                           _ response: HTTPURLResponse?,
                           _ data: Data?,
                           _ error: NSError?) -> DataResponse<SerializedObject> {
        let result = serializeResponse(request, response, data, error)
        return DataResponse(request: request, response: response, data: data, result: result)
    }
}
