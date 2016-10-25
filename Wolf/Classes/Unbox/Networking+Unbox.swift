import Unbox
import Alamofire

public extension HTTPResource where Value: Unboxable {
    func serialize(data: Data?, error: Swift.Error?) -> Result<Value> {
        if let error = error {
            return .failure(error)
        } else if let data = data {
            return decode(data: data)
        } else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
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
    func serialize(data: Data?, error: Swift.Error?) -> Result<[Value.Iterator.Element]> {
        if let error = error {
            return .failure(error)
        } else if let data = data {
            return decodeArray(data: data)
        } else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
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
    func serialize(data: Data?, error: Swift.Error?) -> Result<[Value.Iterator.Element]> {
        if let error = error {
            return .failure(error)
        } else if let data = data, let rootKey = rootKey {
            return decodeArray(data: data, rootKey: rootKey)
        } else if let data = data {
            return decodeArray(data: data)
        } else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
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
            throw UnboxError.invalidData
        }
        return typedObject
    }
}
