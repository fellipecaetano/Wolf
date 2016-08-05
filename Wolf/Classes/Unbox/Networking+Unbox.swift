import Unbox
import Alamofire

public extension HTTPResource where Value: Unboxable, Error == NSError {
    func serialize(data: NSData?, error: NSError?) -> Result<Value, Error> {
        if let error = error {
            return .Failure(error)
        } else if let data = data {
            do {
                let song: Value = try Unbox(data)
                return .Success(song)
            } catch let error {
                return .Failure(error as Error)
            }
        } else {
            return .Failure(NSError(domain: "", code: -1, userInfo: nil))
        }
    }

    func serializeArray(data: NSData?, error: NSError?) -> Result<[Value], Error> {
        if let error = error {
            return .Failure(error)
        } else if let data = data {
            do {
                let song: [Value] = try Unbox(data)
                return .Success(song)
            } catch let error {
                return .Failure(error as Error)
            }
        } else {
            return .Failure(NSError(domain: "", code: -1, userInfo: nil))
        }
    }
}

public extension HTTPResource where Self: JSONEnvelope, Value: Unboxable, Error == NSError {
    func serializeArray(data: NSData?, error: NSError?) -> Result<[Value], Error> {
        if let error = error {
            return .Failure(error)
        } else if let data = data {
            do {
                let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? UnboxableDictionary ?? [:]
                let song: [Value] = try Unbox(dictionary, at: "songs")
                return .Success(song)
            } catch let error {
                return .Failure(error as Error)
            }
        } else {
            return .Failure(NSError(domain: "", code: -1, userInfo: nil))
        }
    }
}
