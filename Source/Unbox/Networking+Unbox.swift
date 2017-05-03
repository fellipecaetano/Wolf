import Unbox
import Alamofire

public extension HTTPResource where Value: Unboxable {
    func serialize(response: Result<Data>) -> Result<Value> {
        switch response {
        case .failure(let error):
            return .failure(error)
        case .success(let data):
            return decode(data: data)
        }
    }
}

private func decode<T: Unboxable>(data: Data) -> Result<T> {
    do {
        let value: T = try unbox(data: data)
        return .success(value)
    } catch let error {
        return .failure(error)
    }
}

public extension HTTPResource where Value: Collection, Value.Iterator.Element: Unboxable {
    func serialize(response: Result<Data>) -> Result<[Value.Iterator.Element]> {
        switch response {
        case .failure(let error):
            return .failure(error)
        case .success(let data):
            return decodeArray(data: data)
        }
    }
}

private func decodeArray<T: Unboxable>(data: Data) -> Result<[T]> {
    do {
        let valueArray: [T] = try unbox(data: data)
        return .success(valueArray)
    } catch let error {
        return .failure(error)
    }
}

public extension HTTPResource where Self: JSONEnvelope, Value: Collection, Value.Iterator.Element: Unboxable {
    func serialize(response: Result<Data>) -> Result<[Value.Iterator.Element]> {
        switch response {
        case .failure(let error):
            return .failure(error)
        case .success(let data):
            if let rootKey = rootKey {
                return decodeArray(data: data, rootKey: rootKey)
            } else {
                return decodeArray(data: data)
            }
        }
    }
}

private func decodeArray<T: Unboxable>(data: Data, rootKey: String) -> Result<[T]> {
    do {
        let dictionary: UnboxableDictionary = try JSONSerialization.JSONObject(with: data, options: [])
        let valueArray: [T] = try unbox(dictionary: dictionary, atKey: rootKey)
        return .success(valueArray)
    } catch let error {
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
