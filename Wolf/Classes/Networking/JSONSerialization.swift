import Foundation
import Alamofire
import Argo

struct JSONResponseSerializer<T: Decodable where T.DecodedType == T>: ResponseSerializerType {
    var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Result<T, JSONResponseError> {
        return { _, _, data, error in
            return self.serialize(data, error: error)
        }
    }

    private func serialize(data: NSData?, error: NSError?) -> Result<T, JSONResponseError> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data {
            return decode(data)
        } else {
            return .Failure(.AbsentData)
        }
    }
}

private func decode<T: Decodable where T.DecodedType == T>(data: NSData) -> Result<T, JSONResponseError> {
    do {
        let JSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        return .Success(try decode(JSONObject).dematerialize())
    } catch let error as DecodeError {
        return .Failure(.InvalidSchema(error))
    } catch let error as NSError {
        return .Failure(.InvalidFormat(error))
    }
}

struct JSONArrayResponseSerializer<T: Decodable where T.DecodedType == T>: ResponseSerializerType {
    private let rootKey: String?

    init (rootKey: String? = nil) {
        self.rootKey = rootKey
    }

    var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Result<[T], JSONResponseError> {
        return { _, _, data, error in
            return self.serialize(data, error: error)
        }
    }

    private func serialize(data: NSData?, error: NSError?) -> Result<[T], JSONResponseError> {
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

private func decodeArray<T: Decodable where T.DecodedType == T>(data: NSData) -> Result<[T], JSONResponseError> {
    do {
        let array: [AnyObject] = try NSJSONSerialization.JSONObject(data, options: [])
        return .Success(try decode(array).dematerialize())
    } catch let error as DecodeError {
        return .Failure(.InvalidSchema(error))
    } catch let error as NSError {
        return .Failure(.InvalidFormat(error))
    }
}

private func decodeArray<T: Decodable where T.DecodedType == T>(data: NSData, rootKey: String) -> Result<[T], JSONResponseError> {
    do {
        let dictionary: [String: AnyObject] = try NSJSONSerialization.JSONObject(data, options: [])
        return .Success(try decode(dictionary, rootKey: rootKey).dematerialize())
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

public extension HTTPClient {
    func sendRequest<R: HTTPResource where R.Value: Decodable, R.Value.DecodedType == R.Value>
        (resource: R, completionHandler: Response<R.Value, JSONResponseError> -> Void) {

        let serializer = JSONResponseSerializer<R.Value>()
        self.request(resource)
            .validate()
            .response(responseSerializer: serializer, completionHandler: completionHandler)
    }

    func sendArrayRequest<R: HTTPResource where R.Value: Decodable, R.Value.DecodedType == R.Value>
        (resource: R, completionHandler: Response<[R.Value], JSONResponseError> -> Void) {

        let serializer = JSONArrayResponseSerializer<R.Value>()
        self.request(resource)
            .validate()
            .response(responseSerializer: serializer, completionHandler: completionHandler)
    }

    func sendArrayRequest<R: protocol<HTTPResource, JSONEnvelope> where R.Value: Decodable, R.Value.DecodedType == R.Value>
        (resource: R, completionHandler: Response<[R.Value], JSONResponseError> -> Void) {

        let serializer = JSONArrayResponseSerializer<R.Value>(rootKey: resource.rootKey)
        self.request(resource)
            .validate()
            .response(responseSerializer: serializer, completionHandler: completionHandler)
    }
}

public enum JSONResponseError: ErrorType {
    case InvalidFormat(NSError)
    case InvalidSchema(DecodeError)
    case FailedRequest(NSError)
    case AbsentData
}

public protocol JSONEnvelope {
    var rootKey: String? { get }
}
