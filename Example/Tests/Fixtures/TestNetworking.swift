import Foundation
import Wolf
import Alamofire
import Argo

class ExampleClient: HTTPClient {
    var baseURL: NSURL {
        return NSURL(string: "http://example.com")!
    }

    let manager: Manager

    init() {
        manager = Manager()
    }
}

struct User {
    let username: String
}

extension User: Decodable {
    static func decode(json: JSON) -> Decoded<User> {
        return self.init
            <^> json <| "username"
    }
}

extension User {
    enum Resource: HTTPResource {
        typealias Value = User
        typealias Error = ArgoResponseError

        case getUser
        case getInvalidUser
        case getInvalidJSON
        case getUsers

        var path: String {
            switch self {
            case .getUser:
                return "get/user"

            case .getInvalidUser:
                return "get/invalid_user"

            case .getInvalidJSON:
                return "get/invalid_json"

            case .getUsers:
                return "get/users"
            }
        }
    }

    enum ResourceCollection: HTTPResource, JSONEnvelope {
        typealias Value = User
        typealias Error = ArgoResponseError

        case getEnvelopedUsers

        var path: String {
            switch self {
            case .getEnvelopedUsers:
                return "get/enveloped_users"
            }
        }

        var rootKey: String? {
            return "users"
        }
    }
}
