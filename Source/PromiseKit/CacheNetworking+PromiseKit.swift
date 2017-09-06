import PromiseKit

public extension HTTPClient {
    func sendRequest<R: HTTPResource & CacheableResource>(_ resource: R) -> Promise<R.Value> {
        
        return Promise<R.Value>(.pending) { resolver in
            self.sendRequest(resource) { response in
                switch response.result {
                case .success(let value):
                    resolver.fulfill(value)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
    }
}
