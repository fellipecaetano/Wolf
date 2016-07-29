import Foundation
import Alamofire

public protocol HTTPClient {
    var baseURL: NSURL { get }
    var manager: Manager { get }
}

public extension HTTPClient {
    func request<R: HTTPResource>(resource: R) -> Request {
        let target = HTTPTarget(baseURL: baseURL, resource: resource)
        return manager.request(target)
    }

    func sendRequest<R: HTTPResource>(resource: R, completionHandler: Response<R.Value, R.Error> -> Void) -> Request {
        return request(resource)
            .validate()
            .response(responseSerializer: resource.responseSerializer, completionHandler: completionHandler)
    }

    func sendArrayRequest<R: HTTPResource>(resource: R, completionHandler: Response<[R.Value], R.Error> -> Void) -> Request {
        return request(resource)
            .validate()
            .response(responseSerializer: resource.arrayResponseSerializer, completionHandler: completionHandler)
    }
}

public protocol HTTPResource {
    associatedtype Value
    associatedtype Error: ErrorType

    var path: String { get }
    var method: Alamofire.Method { get }
    var parameters: [String: AnyObject]? { get }
    var headers: [String: String]? { get }
    var parameterEncoding: ParameterEncoding { get }

    func serialize(data: NSData?, error: NSError?) -> Result<Value, Error>
    func serializeArray(data: NSData?, error: NSError?) -> Result<[Value], Error>
}

public extension HTTPResource {
    var method: Alamofire.Method {
        return .GET
    }

    var parameters: [String: AnyObject]? {
        return nil
    }

    var headers: [String: String]? {
        return nil
    }

    var parameterEncoding: ParameterEncoding {
        return .URL
    }

    var responseSerializer: ResponseSerializer<Value, Error> {
        return ResponseSerializer { _, _, data, error in
            return self.serialize(data, error: error)
        }
    }

    var arrayResponseSerializer: ResponseSerializer<[Value], Error> {
        return ResponseSerializer { _, _, data, error in
            return self.serializeArray(data, error: error)
        }
    }
}

struct HTTPTarget<R: HTTPResource>: HTTPTargetProtocol {
    let baseURL: NSURL
    let resource: R
}

protocol HTTPTargetProtocol {
    associatedtype Resource: HTTPResource

    var baseURL: NSURL { get }
    var resource: Resource { get }
}

extension HTTPTargetProtocol {
    var URL: NSURL {
        return baseURL.URLByAppendingPathComponent(resource.path)
    }
}

private extension Manager {
    func request<T: HTTPTargetProtocol>(target: T) -> Request {
        return request(target.resource.method,
                       target.URL.absoluteString,
                       parameters: target.resource.parameters,
                       encoding: target.resource.parameterEncoding,
                       headers: target.resource.headers)
    }
}
