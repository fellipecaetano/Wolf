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
        case getSongs

        var path: String {
            switch self {
            case .getSong:
                return "song"
            case .getSongs:
                return "songs"
            }
        }

        func serialize(data: NSData?, error: NSError?) -> Result<Song, NSError> {
            if let error = error {
                return .Failure(error)
            } else if let data = data {
                do {
                    let song: Song = try Unbox(data)
                    return .Success(song)
                } catch let error {
                    return .Failure(error as NSError)
                }
            } else {
                return .Failure(NSError(domain: "", code: -1, userInfo: nil))
            }
        }

        func serializeArray(data: NSData?, error: NSError?) -> Result<[Song], NSError> {
            if let error = error {
                return .Failure(error)
            } else if let data = data {
                do {
                    let song: [Song] = try Unbox(data)
                    return .Success(song)
                } catch let error {
                    return .Failure(error as NSError)
                }
            } else {
                return .Failure(NSError(domain: "", code: -1, userInfo: nil))
            }
        }
    }
}
