import PromiseKit

public extension HTTPClient {
    func sendRequest<R: HTTPResource & CacheableResource>(_ resource: R) -> Promise<R.Value> {
        return Promise { fulfill, reject in
            self.sendRequest(resource) { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
}
