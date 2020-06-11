import Foundation
import Alamofire
import Wolf

class TestClient: HTTPClient {
    var baseURL: URL {
        return URL(string: "http://example.com")!
    }

    let manager: SessionManager

    init() {
        manager = SessionManager()
    }
}
