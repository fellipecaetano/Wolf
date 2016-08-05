import Argo
import Alamofire

public extension HTTPResource where Value: Decodable, Value.DecodedType == Value, Error == ArgoResponseError {
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

private func decode<T: Decodable where T.DecodedType == T>(data: NSData) -> Result<T, ArgoResponseError> {
    do {
        let JSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        return try .Success(decode(JSONObject).dematerialize())
    } catch let error as DecodeError {
        return .Failure(.InvalidSchema(error))
    } catch let error as NSError {
        return .Failure(.InvalidFormat(error))
    }
}

private func decodeArray<T: Decodable where T.DecodedType == T>(data: NSData) -> Result<[T], ArgoResponseError> {
    do {
        let array: [AnyObject] = try NSJSONSerialization.JSONObject(data, options: [])
        return try .Success(decode(array).dematerialize())
    } catch let error as DecodeError {
        return .Failure(.InvalidSchema(error))
    } catch let error as NSError {
        return .Failure(.InvalidFormat(error))
    }
}

public extension HTTPResource where Self: JSONEnvelope, Value: Decodable, Value.DecodedType == Value, Error == ArgoResponseError {
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

private func decodeArray<T: Decodable where T.DecodedType == T>(data: NSData, rootKey: String) -> Result<[T], ArgoResponseError> {
    do {
        let dictionary: [String: AnyObject] = try NSJSONSerialization.JSONObject(data, options: [])
        return try .Success(decode(dictionary, rootKey: rootKey).dematerialize())
    } catch let error as DecodeError {
        return .Failure(.InvalidSchema(error))
    } catch let error as NSError {
        return .Failure(.InvalidFormat(error))
    }
}

private extension NSJSONSerialization {
    static func JSONObject<T>(data: NSData, options: NSJSONReadingOptions) throws -> T {
        let JSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: options)
        guard let typedObject = JSONObject as? T else {
            throw DecodeError.TypeMismatch(expected: "\(T.self)",
                                           actual: "\(JSONObject.dynamicType)")
        }
        return typedObject
    }
}

public enum ArgoResponseError: ErrorType {
    case InvalidFormat(NSError)
    case InvalidSchema(DecodeError)
    case FailedRequest(NSError)
    case AbsentData
}
