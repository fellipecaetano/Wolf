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

    enum EnvelopedArrayResource: HTTPResource {
        typealias Value = [Song]

        case getEnvelopedSongs

        var path: String {
            switch self {
            case .getEnvelopedSongs:
                return "songs/enveloped"
            }
        }

        var rootKey: String? {
            switch self {
            case .getEnvelopedSongs:
                return "songs"
            }
        }
    }
}
