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
        typealias Error = NSError

        case getSong

        var path: String {
            switch self {
            case .getSong:
                return "song"
            }
        }

        func serialize(data: NSData?, error: NSError?) -> Result<Song, NSError> {
            return .Failure(NSError(domain: "", code: -1, userInfo: nil))
        }

        func serializeArray(data: NSData?, error: NSError?) -> Result<[Song], NSError> {
            return .Failure(NSError(domain: "", code: -1, userInfo: nil))
        }
    }
}
