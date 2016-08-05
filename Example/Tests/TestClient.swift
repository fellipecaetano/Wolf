import Alamofire
import Wolf

class TestClient: HTTPClient {
    var baseURL: NSURL {
        return NSURL(string: "http://example.com")!
    }

    let manager: Manager

    init() {
        manager = Manager()
    }
}
