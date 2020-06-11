import Alamofire
import Foundation

public extension HTTPResource where Value: Decodable {
    func serialize(response: Result<Data>) -> SerializationResult<Value> {
        switch response {
        case let .failure(error):
            return .failure(error)
        case let .success(data):
            return decode(data: data, withRootKey: rootKey)
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

private func decode<T: Decodable>(data: Data, withRootKey key: String?) -> SerializationResult<T> {
    do {
        if let rootKey = key {
            let decodedDictionary: [String: T] = try JSONDecoder().decode([String: T].self, from: data)
            guard let value = decodedDictionary[rootKey] else {
                return .failure(HTTPResourceError.emptyData)
            }
            return .success(value)
        }
        return decode(data: data)
    } catch {
        return .failure(error)
    }
}
