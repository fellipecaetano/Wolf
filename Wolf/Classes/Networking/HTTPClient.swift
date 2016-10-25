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
        return sendRequest(request(resource),
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

public protocol HTTPResource {
    associatedtype Value
    associatedtype Error: Swift.Error

    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: [String: String]? { get }
    var parameterEncoding: ParameterEncoding { get }

    func serialize(_ data: Data?, error: Swift.Error?) -> Result<Value>
}

public extension HTTPResource {
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
            return self.serialize(data, error: error)
        }
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
