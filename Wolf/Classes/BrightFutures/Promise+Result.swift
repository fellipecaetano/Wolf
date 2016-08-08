import Alamofire
import BrightFutures

extension Promise {
    func result(result: Result<T, E>) {
        switch result {
        case .Success(let value): success(value)
        case .Failure(let error): failure(error)
        }
    }
}
