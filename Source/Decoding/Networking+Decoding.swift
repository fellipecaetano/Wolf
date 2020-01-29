import Alamofire

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

public extension HTTPResource where Value: Collection, Value.Iterator.Element: Decodable {
    func serialize(response: Result<Data>) -> SerializationResult<[Value.Iterator.Element]> {
        switch response {
        case let .failure(error):
            return .failure(error)
        case let .success(data):
            return decodeArray(data: data)
        }
    }
}

private func decodeArray<T: Decodable>(data: Data) -> SerializationResult<[T]> {
    do {
        let valueArray: [T] = try JSONDecoder().decode([T].self, from: data)
        return valueArray
    } catch {
        return .failure(error)
    }
}

public extension HTTPResource where Self: JSONEnvelope, Value: Collection, Value.Iterator.Element: Decodable {
    func serialize(response: Result<Data>) -> SerializationResult<[Value.Iterator.Element]> {
        switch response {
        case let .failure(error):
            return .failure(error)
        case let .success(data):
            if let rootKey = rootKey {
                return decodeArray(data: data, withRootKey: rootKey)
            }
            return decodeArray(data: data)
        }
    }
}

private func decodeArray<T: Decodable>(data: Data, withRootKey rootKey: String) -> SerializationResult<[T]> {
    do {
        let dictionary: [String: [T]] = try JSONDecoder().decode([String: [T]].self, from: data)
        return .success(dictionary[rootKey])
    } catch {
        return .failure(error)
    }
}

private extension JSONSerialization {
    static func JSONObject<T>(with data: Data, options: JSONSerialization.ReadingOptions) throws -> T {
        let JSONObject = try JSONSerialization.jsonObject(with: data, options: options)
        guard let typedObject = JSONObject as? T else {
            return NSError(domain: NSCocoaErrorDomain, code: 3840, userInfo: ["dirtyObject": JSONObject])
        }
        return typedObject
    }
}
