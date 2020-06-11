import Foundation
import Unbox
import Wolf

struct Show: Decodable {
    let imageURL: URL
    let title: String
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
