import Argo
import Wolf

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
        case getUsers
        case getInvalidSchemaUser
        case getInvalidFormatUser

        var path: String {
            switch self {
            case .getUser:
                return "user"

            case .getUsers:
                return "users"

            case .getInvalidSchemaUser:
                return "user/invalid_schema"

            case .getInvalidFormatUser:
                return "user/invalid_format"
            }
        }
    }

    enum EnvelopedResource: HTTPResource, JSONEnvelope {
        typealias Value = User
        typealias Error = ArgoResponseError

        case getEnvelopedUsers

        var path: String {
            switch self {
            case .getEnvelopedUsers:
                return "users/enveloped"
            }
        }

        var rootKey: String? {
            return "users"
        }
    }
}
