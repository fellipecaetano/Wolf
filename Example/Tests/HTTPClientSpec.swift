import Foundation
import Quick
import Nimble
import OHHTTPStubs
import Alamofire
import Wolf

class HTTPClientSpec: QuickSpec {
    override func spec() {
        afterEach {
            OHHTTPStubs.removeAllStubs()
        }

        describe("a HTTPClient") {
            let client = ExampleClient()
            
            describe("sending object requests") {
                context("when the request is sucessful") {
                    stub(isHost("http://example.com") && isPath("get/success")) {
                        
                    }
                }
            }
        }
    }
}

class ExampleClient: HTTPClient {
    var baseURL: NSURL {
        return NSURL(string: "http://example.com")!
    }
    
    let manager: Manager
    
    init() {
        manager = Manager()
    }
}
