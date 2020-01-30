import Foundation
import Alamofire

public protocol HTTPClient {
    var baseURL: URL { get }
    var manager: SessionManager { get }

    @discardableResult
    func sendRequest<S: DataResponseSerializerProtocol>(_ request: DataRequest,
                     responseSerializer: S,
                     completionHandler: @escaping (DataResponse<S.SerializedObject>) -> Void) -> DataRequest
}

public extension HTTPClient {
    func request<R: HTTPResource>(_ resource: R) -> DataRequest {
        let target = HTTPTarget(baseURL: baseURL, resource: resource)
        return manager.request(target)
    }

    @discardableResult
    func sendRequest<R: HTTPResource>(_ resource: R, completionHandler: @escaping (DataResponse<R.Value>) -> Void) -> DataRequest {
        return sendRequest(request(resource).validate(resource.validate),
                           responseSerializer: resource.responseSerializer,
                           completionHandler: completionHandler)
    }

    @discardableResult
    func sendRequest<S: DataResponseSerializerProtocol>(_ request: DataRequest,
                     responseSerializer: S,
                     completionHandler: @escaping (DataResponse<S.SerializedObject>) -> Void) -> DataRequest {
        return request.validate().response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

enum HTTPResourceError: Error {
    case emptyData
    case serializationFailure(reason: String)
}

public enum SerializationResult<Value> {
    case failure(Error)
    case serializationFailure(reason: String)
    case success(Value)

    internal var resultProxy: Result<Value> {
        switch self {
        case .failure(let error):
            return .failure(error)
        case .serializationFailure(let reason):
            return .failure(HTTPResourceError.serializationFailure(reason: reason))
        case .success(let value):
            return .success(value)
        }
    }
}

public protocol HTTPResource {
    associatedtype Value

    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: [String: String]? { get }
    var parameterEncoding: ParameterEncoding { get }

    func validate(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult
    func serialize(response result: Result<Data>) -> SerializationResult<Value>
}

public extension HTTPResource {

    var rootKey: String? { return nil }
    
    var method: HTTPMethod {
        return .get
    }

    var parameters: Parameters? {
        return nil
    }

    var headers: [String: String]? {
        return nil
    }

    var parameterEncoding: ParameterEncoding {
        return URLEncoding()
    }

    var responseSerializer: DataResponseSerializer<Value> {
        return DataResponseSerializer { _, _, data, error in
            if let error = error {
                return self.serialize(response: .failure(error)).resultProxy
            } else if let data = data {
                return self.serialize(response: .success(data)).resultProxy
            } else {
                return self.serialize(response: .failure(HTTPResourceError.emptyData)).resultProxy
            }
        }
    }

    func validate(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
        return .success
    }
}

struct HTTPTarget<R: HTTPResource>: HTTPTargetProtocol {
    let baseURL: URL
    let resource: R
}

protocol HTTPTargetProtocol {
    associatedtype Resource: HTTPResource

    var baseURL: Foundation.URL { get }
    var resource: Resource { get }
}

extension HTTPTargetProtocol {
    var URL: Foundation.URL {
        return baseURL.appendingPathComponent(resource.path)
    }
}

private extension SessionManager {
    func request<T: HTTPTargetProtocol>(_ target: T) -> DataRequest {
        return request(target.URL,
                       method: target.resource.method,
                       parameters: target.resource.parameters,
                       encoding: target.resource.parameterEncoding,
                       headers: target.resource.headers)
    }
}
