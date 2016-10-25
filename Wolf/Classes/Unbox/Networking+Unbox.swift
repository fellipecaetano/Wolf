import Unbox
import Alamofire

public extension HTTPResource where Value: Unboxable {
    func serialize(_ data: Data?, error: Swift.Error?) -> Result<Value> {
        if let error = error {
            return .failure(error)
        } else if let data = data {
            return decode(data)
        } else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
        }
    }
}

private func decode<T: Unboxable>(_ data: Data) -> Result<T> {
    do {
        let value: T = try unbox(data: data)
        return .success(value)
    } catch let error {
        return .failure(error)
    }
}

public extension HTTPResource where Value: Collection, Value.Iterator.Element: Unboxable {
    func serialize(_ data: Data?, error: Swift.Error?) -> Result<[Value.Iterator.Element]> {
        if let error = error {
            return .failure(error)
        } else if let data = data {
            return decodeArray(data)
        } else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
        }
    }
}

private func decodeArray<T: Unboxable>(_ data: Data) -> Result<[T]> {
    do {
        let valueArray: [T] = try unbox(data: data)
        return .success(valueArray)
    } catch let error {
        return .failure(error)
    }
}

public extension HTTPResource where Self: JSONEnvelope, Value: Collection, Value.Iterator.Element: Unboxable {
    func serialize(_ data: Data?, error: Swift.Error?) -> Result<[Value.Iterator.Element]> {
        if let error = error {
            return .failure(error)
        } else if let data = data, let rootKey = rootKey {
            return decodeArray(data, rootKey: rootKey)
        } else if let data = data {
            return decodeArray(data)
        } else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
        }
    }
}

private func decodeArray<T: Unboxable>(_ data: Data, rootKey: String) -> Result<[T]> {
    do {
        let dictionary: UnboxableDictionary = try JSONSerialization.JSONObject(data, options: [])
        let valueArray: [T] = try unbox(dictionary:dictionary, atKey: rootKey)
        return .success(valueArray)
    } catch let error {
        return .failure(error)
    }
}

private extension JSONSerialization {
    static func JSONObject<T>(_ data: Data, options: JSONSerialization.ReadingOptions) throws -> T {
        let JSONObject = try JSONSerialization.jsonObject(with: data, options: options)
        guard let typedObject = JSONObject as? T else {
            throw UnboxError.invalidData
        }
        return typedObject
    }
}
