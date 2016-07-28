import Foundation
import Alamofire
import Argo

enum JSONResponseError: ErrorType {
    case FoundationDecode(NSError)
    case ArgoDecode(DecodeError)
    case Request(NSError)
    case DataAbsence
}

struct JSONResponseSerializer<T: Decodable where T.DecodedType == T>: ResponseSerializerType {
    var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Result<T, JSONResponseError> {
        return { _, _, data, error in
            return self.serialize(data, error: error)
        }
    }
    
    private func serialize(data: NSData?, error: NSError?) -> Result<T, JSONResponseError> {
        if let error = error {
            return .Failure(.Request(error))
        } else if let data = data {
            return decode(data)
        } else {
            return .Failure(.DataAbsence)
        }
    }
}

struct JSONArrayResponseSerializer<T: Decodable where T.DecodedType == T>: ResponseSerializerType {
    var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Result<[T], JSONResponseError> {
        return { _, _, data, error in
            return self.serialize(data, error: error)
        }
    }
    
    private func serialize(data: NSData?, error: NSError?) -> Result<[T], JSONResponseError> {
        if let error = error {
            return .Failure(.Request(error))
        } else if let data = data {
            return decodeArray(data, rootKey: "data")
        } else {
            return .Failure(.DataAbsence)
        }
    }
}

private func decode<T: Decodable where T.DecodedType == T>(data: NSData) -> Result<T, JSONResponseError> {
    do {
        let JSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        return .Success(try decode(JSONObject).dematerialize())
    } catch let error as DecodeError {
        return .Failure(.ArgoDecode(error))
    } catch let error as NSError {
        return .Failure(.FoundationDecode(error))
    }
}

private func decodeArray<T: Decodable where T.DecodedType == T>(data: NSData, rootKey: String) -> Result<[T], JSONResponseError> {
    do {
        let dictionary: [String: AnyObject] = try NSJSONSerialization.JSONObject(data, options: [])
        return .Success(try decode(dictionary, rootKey: rootKey).dematerialize())
    } catch let error as DecodeError {
        return .Failure(.ArgoDecode(error))
    } catch let error as NSError {
        return .Failure(.FoundationDecode(error))
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
