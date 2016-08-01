import Foundation
import Alamofire
import Wolf

class TVGuideClient: HTTPClient {
    var baseURL: NSURL {
        return NSURL(string: "https://tvguide.com")!
    }

    let manager = Manager()
}
