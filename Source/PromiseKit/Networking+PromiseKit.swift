import PromiseKit

public extension HTTPClient {
    func sendRequest<R: HTTPResource>(_ resource: R) -> Promise<R.Value> {
        return Promise { seal in
            self.sendRequest(resource) { response in
                switch response.result {
                case .success(let value):
                    seal.fulfill(value)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
