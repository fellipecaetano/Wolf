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

private extension JSONSerialization {
    static func JSONObject<T>(with data: Data, options: JSONSerialization.ReadingOptions) throws -> T {
        let JSONObject = try JSONSerialization.jsonObject(with: data, options: options)
        guard let typedObject = JSONObject as? T else {
            throw NSError(domain: NSCocoaErrorDomain, code: 3840, userInfo: ["dirtyObject": JSONObject])
        }
        return typedObject
    }
}
