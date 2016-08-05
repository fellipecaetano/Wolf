import Unbox
import Alamofire
import Wolf

struct Song {
    let title: String
}

extension Song: Unboxable {
    init(unboxer: Unboxer) {
        title = unboxer.unbox("title")
    }
}

extension Song {
    enum Resource: HTTPResource {
        typealias Value = Song
        typealias Error = UnboxResponseError

        case getSong
        case getSongs

        var path: String {
            switch self {
            case .getSong:
                return "song"
            case .getSongs:
                return "songs"
            }
        }
    }

    enum EnvelopedResource: HTTPResource, JSONEnvelope {
        typealias Value = Song
        typealias Error = UnboxResponseError

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
