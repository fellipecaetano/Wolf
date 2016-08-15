import Unbox
import Alamofire

public extension HTTPResource where Value: Unboxable, Error == UnboxResponseError {
    func serialize(data: NSData?, error: NSError?) -> Result<Value, Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data {
            return decode(data)
        } else {
            return .Failure(.AbsentData)
        }
    }

    func serializeArray(data: NSData?, error: NSError?) -> Result<[Value], Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data {
            return decodeArray(data)
        } else {
            return .Failure(.AbsentData)
        }
    }
}

public extension HTTPResource
    where Value: CollectionType,
    Value.Generator.Element: Unboxable,
    Error == UnboxResponseError {

    func serialize(data: NSData?, error: NSError?) -> Result<[Value.Generator.Element], Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data {
            return decodeArray(data)
        } else {
            return .Failure(.AbsentData)
        }
    }

    func serializeArray(data: NSData?, error: NSError?) -> Result<[Value], Error> {
        return .Success([])
    }
}

private func decode<T: Unboxable>(data: NSData) -> Result<T, UnboxResponseError> {
    do {
        let value: T = try Unbox(data)
        return .Success(value)
    } catch let error as UnboxError {
        return .Failure(.InvalidSchema(error))
    } catch let error {
        return .Failure(.UnknownFailure(error))
    }
}

private func decodeArray<T: Unboxable>(data: NSData) -> Result<[T], UnboxResponseError> {
    do {
        let valueArray: [T] = try Unbox(data)
        return .Success(valueArray)
    } catch let error as UnboxError {
        return .Failure(.InvalidSchema(error))
    } catch let error {
        return .Failure(.UnknownFailure(error))
    }
}

public extension HTTPResource where Self: JSONEnvelope, Value: Unboxable, Error == UnboxResponseError {
    func serializeArray(data: NSData?, error: NSError?) -> Result<[Value], Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data, rootKey = rootKey {
            return decodeArray(data, rootKey: rootKey)
        } else if let data = data {
            return decodeArray(data)
        } else {
            return .Failure(.AbsentData)
        }
    }
}

public extension HTTPResource
    where Self: JSONEnvelope,
    Value: CollectionType,
    Value.Generator.Element: Unboxable,
    Error == UnboxResponseError {

    func serialize(data: NSData?, error: NSError?) -> Result<[Value.Generator.Element], Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data, rootKey = rootKey {
            return decodeArray(data, rootKey: rootKey)
        } else if let data = data {
            return decodeArray(data)
        } else {
            return .Failure(.AbsentData)
        }
    }

    func serializeArray(data: NSData?, error: NSError?) -> Result<[Value], Error> {
        return .Success([])
    }
}

private func decodeArray<T: Unboxable>(data: NSData, rootKey: String) -> Result<[T], UnboxResponseError> {
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

private extension NSJSONSerialization {
    static func JSONObject<T>(data: NSData, options: NSJSONReadingOptions) throws -> T {
        let JSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: options)
        guard let typedObject = JSONObject as? T else {
            throw UnboxError.InvalidData
        }
        return typedObject
    }
}

public enum UnboxResponseError: ErrorType {
    case FailedRequest(NSError)
    case InvalidSchema(UnboxError)
    case InvalidFormat(NSError)
    case AbsentData
    case UnknownFailure(ErrorType)
}
