import Foundation
import Unbox
import Wolf

struct Show {
    let imageURL: URL
    let title: String
}

extension Show: Unboxable {
    init(unboxer: Unboxer) throws {
        imageURL = try unboxer.unbox(keyPath: "images.poster.thumb")
        title = try unboxer.unbox(key: "title")
    }
}

extension Show {
    static var getPopularShows: Resource {
        return .getPopularShows
    }

    enum Resource: HTTPResource {
        typealias Value = [Show]

        case getPopularShows

        var path: String {
            switch self {
            case .getPopularShows:
                return "shows/popular"
            }
        }
    }
}
