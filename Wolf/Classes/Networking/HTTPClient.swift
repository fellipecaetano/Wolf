import Foundation
import Alamofire
import Argo

public protocol HTTPClient {
    var baseURL: NSURL { get }
    var manager: Manager { get }
}

extension HTTPClient {
    func sendRequest<R: HTTPResource where R.Value: Decodable, R.Value.DecodedType == R.Value>
        (resource: R, completionHandler: Response<R.Value, JSONResponseError> -> Void)
    {
        let serializer = JSONResponseSerializer<R.Value>()
        self.request(resource)
            .validate()
            .response(responseSerializer: serializer, completionHandler: completionHandler)
    }

    func sendArrayRequest<R: HTTPResource where R.Value: Decodable, R.Value.DecodedType == R.Value>
        (resource: R, completionHandler: Response<[R.Value], JSONResponseError> -> Void)
    {
        let serializer = JSONArrayResponseSerializer<R.Value>()
        self.request(resource)
            .validate()
            .response(responseSerializer: serializer, completionHandler: completionHandler)
    }

    func request<R: HTTPResource>(resource: R) -> Request {
        let target = HTTPTarget(baseURL: baseURL, resource: resource)
        return manager.request(target)
    }
}

protocol HTTPResource {
    associatedtype Value
    
    var path: String { get }
    var method: Alamofire.Method { get }
    var parameters: [String: AnyObject]? { get }
    var headers: [String: String]? { get }
    var parameterEncoding: ParameterEncoding { get }
}

extension HTTPResource {
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
