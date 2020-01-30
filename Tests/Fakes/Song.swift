import Foundation
import Alamofire
import Wolf

struct Song: Codable {
    let title: String
}

extension Song {
    enum Resource: HTTPResource {
        typealias Value = Song

        case getSong
        case getValidatedSong(Error)
        case getSongs
        case getInvalidSchemaSong
        case getInvalidFormatSong

        var path: String {
            switch self {
            case .getSong, .getValidatedSong:
                return "song"
            case .getSongs:
                return "songs"
            case .getInvalidSchemaSong:
                return "songs/invalid_schema"
            case .getInvalidFormatSong:
                return "songs/invalid_format"
            }
        }

        func validate(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
            switch self {
            case .getValidatedSong(let error):
                return .failure(error)
            default:
                return .success
            }
        }
    }

    enum FlatArrayResource: HTTPResource {
        typealias Value = [Song]

        case getSongs

        var path: String {
            switch self {
            case .getSongs:
                return "songs"
            }
        }
    }

    enum EnvelopedArrayResource: HTTPResource, JSONEnvelope {
        typealias Value = [Song]

        case getEnvelopedSongs

        var path: String {
            switch self {
            case .getEnvelopedSongs:
                return "songs/enveloped"
            }
        }

        var rootKey: String {
            switch self {
            case .getEnvelopedSongs:
                return "songs"
            }
        }

        func serialize(response: Result<Data>) -> SerializationResult<[Song]> {
            switch response {
            case let .success(data):
                do {
                    let object = try JSONDecoder().decode([String: [Song]].self, from: data)
                    guard let result = object[rootKey] else {
                        return .serializationFailure(reason: "Empty Data")
                    }
                    return .success(result)
                } catch {
                    return .failure(error)
                }
            case let .failure(error):
                return .failure(error)
            }
        }
    }
}
