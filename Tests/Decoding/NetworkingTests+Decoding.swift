import XCTest
import OHTTPStubs
import Nimble
import Wolf

class DecodingNetworkingTests: XCTestCase {
    private let client = TestClient()

    override func tearDown() {
        OHTTPStubs.removeAllStubs()
    }
}
