import XCTest
import OHHTTPStubs
import Nimble

class UnboxNetworkingTests: XCTestCase {
    private let client = ExampleClient()

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testSuccessfulRequestForObject() {
        stub(isPath("/get/user")) { _ in
            return fixture(OHPathForFile("user.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            done()
        }
    }
}
