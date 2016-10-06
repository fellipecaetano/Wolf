import Alamofire
import BrightFutures

extension Promise {
    func result(_ result: Result<T>) {
        switch result {
        case .success(let value): success(value)
        case .failure(let error as E): failure(error)
        default: break
        }
    }
}
