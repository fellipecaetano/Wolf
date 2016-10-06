import Foundation
import Alamofire
import Wolf

class TVGuideClient: HTTPClient {
    var baseURL: URL {
        return URL(string: "https://tvguide.com")!
    }

    let manager = SessionManager()
}
