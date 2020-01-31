import Alamofire
import Foundation

public extension HTTPResource where Value: Decodable {
    func serialize(response: Result<Data>) -> SerializationResult<Value> {
        switch response {
        case let .failure(error):
            return .failure(error)
        case let .success(data):
            return decode(data: data)
        }
    }
}

private func decode<T: Decodable>(data: Data) -> SerializationResult<T> {
    do {
        let value: T = try JSONDecoder().decode(T.self, from: data)
        return .success(value)
    } catch {
        return .failure(error)
    }
}
