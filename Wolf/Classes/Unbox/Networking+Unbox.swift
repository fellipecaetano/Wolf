import Unbox
import Alamofire

public extension HTTPResource where Value: Unboxable, Error == UnboxResponseError {
    func serialize(data: NSData?, error: NSError?) -> Result<Value, Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data {
            do {
                let song: Value = try Unbox(data)
                return .Success(song)
            } catch let error as UnboxError {
                return .Failure(.InvalidSchema(error))
            } catch let error as NSError {
                return .Failure(.InvalidFormat(error))
            }
        } else {
            return .Failure(.AbsentData)
        }
    }

    func serializeArray(data: NSData?, error: NSError?) -> Result<[Value], Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data {
            do {
                let song: [Value] = try Unbox(data)
                return .Success(song)
            } catch let error as UnboxError {
                return .Failure(.InvalidSchema(error))
            } catch let error as NSError {
                return .Failure(.InvalidFormat(error))
            }
        } else {
            return .Failure(.AbsentData)
        }
    }
}

public extension HTTPResource where Self: JSONEnvelope, Value: Unboxable, Error == UnboxResponseError {
    func serializeArray(data: NSData?, error: NSError?) -> Result<[Value], Error> {
        if let error = error {
            return .Failure(.FailedRequest(error))
        } else if let data = data {
            do {
                let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? UnboxableDictionary ?? [:]
                let song: [Value] = try Unbox(dictionary, at: "songs")
                return .Success(song)
            } catch let error as UnboxError {
                return .Failure(.InvalidSchema(error))
            } catch let error as NSError {
                return .Failure(.InvalidFormat(error))
            }
        } else {
            return .Failure(.AbsentData)
        }
    }
}

public enum UnboxResponseError: ErrorType {
    case InvalidFormat(NSError)
    case InvalidSchema(UnboxError)
    case FailedRequest(NSError)
    case AbsentData
}
