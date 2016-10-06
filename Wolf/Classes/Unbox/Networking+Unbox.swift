import Unbox
import Alamofire

public extension HTTPResource where Value: Unboxable, Error == UnboxResponseError {
    func serialize(_ data: NSData?, error: NSError?) -> Result<Value, Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data {
            return decode(data)
        } else {
            return .Failure(.AbsentData)
        }
    }
}

private func decode<T: Unboxable>(_ data: Data) -> Result<T, UnboxResponseError> {
    do {
        let value: T = try Unbox(data)
        return .Success(value)
    } catch let error as UnboxError {
        return .Failure(.InvalidSchema(error))
    } catch let error {
        return .Failure(.UnknownFailure(error))
    }
}

public extension HTTPResource
    where Value: Collection,
    Value.Iterator.Element: Unboxable,
    Error == UnboxResponseError {

    func serialize(_ data: NSData?, error: NSError?) -> Result<[Value.Generator.Element], Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data {
            return decodeArray(data)
        } else {
            return .Failure(.AbsentData)
        }
    }
}

private func decodeArray<T: Unboxable>(_ data: Data) -> Result<[T], UnboxResponseError> {
    do {
        let valueArray: [T] = try Unbox(data)
        return .Success(valueArray)
    } catch let error as UnboxError {
        return .Failure(.InvalidSchema(error))
    } catch let error {
        return .Failure(.UnknownFailure(error))
    }
}

public extension HTTPResource
    where Self: JSONEnvelope,
    Value: Collection,
    Value.Iterator.Element: Unboxable,
    Error == UnboxResponseError {

    func serialize(_ data: NSData?, error: NSError?) -> Result<[Value.Generator.Element], Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data, let rootKey = rootKey {
            return decodeArray(data, rootKey: rootKey)
        } else if let data = data {
            return decodeArray(data)
        } else {
            return .Failure(.AbsentData)
        }
    }
}

private func decodeArray<T: Unboxable>(_ data: Data, rootKey: String) -> Result<[T], UnboxResponseError> {
    do {
        let dictionary: UnboxableDictionary = try NSJSONSerialization.JSONObject(data, options: [])
        let valueArray: [T] = try Unbox(dictionary, at: rootKey)
        return .Success(valueArray)
    } catch let error as UnboxError {
        return .Failure(.InvalidSchema(error))
    } catch let error as NSError {
        return .Failure(.InvalidFormat(error))
    }
}

private extension JSONSerialization {
    static func JSONObject<T>(_ data: Data, options: JSONSerialization.ReadingOptions) throws -> T {
        let JSONObject = try JSONSerialization.jsonObject(with: data, options: options)
        guard let typedObject = JSONObject as? T else {
            throw UnboxError.InvalidData
        }
        return typedObject
    }
}

public enum UnboxResponseError: Error {
    case failedRequest(NSError)
    case invalidSchema(UnboxError)
    case invalidFormat(NSError)
    case absentData
    case unknownFailure(Error)
}
