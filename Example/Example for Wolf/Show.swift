import Foundation
import Argo
import Curry
import Wolf

struct Show {
    let imageURL: NSURL
    let title: String
}

extension Show: Decodable {
    static func decode(json: JSON) -> Decoded<Show> {
        return curry(self.init)
            <^> json <| ["images", "poster", "thumb"]
            <*> json <| "title"
    }
}

extension Show {
    static var getPopularShows: Resource {
        return .getPopularShows
    }

    enum Resource: HTTPResource {
        typealias Value = Show
        typealias Error = ArgoResponseError

        case getPopularShows

        var path: String {
            switch self {
            case .getPopularShows:
                return "shows/popular"
            }
        }
    }
}
