import BrightFutures

public extension HTTPClient {
    func sendRequest<R: protocol<HTTPResource, CacheableResource>>(resource: R) -> Future<R.Value, R.Error> {
        let promise = Promise<R.Value, R.Error>()
        sendRequest(resource) { promise.result($0.result) }
        return promise.future
    }

    func sendArrayRequest<R: protocol<HTTPResource, CacheableResource>>(resource: R) -> Future<[R.Value], R.Error> {
        let promise = Promise<[R.Value], R.Error>()
        sendArrayRequest(resource) { promise.result($0.result) }
        return promise.future
    }
}
