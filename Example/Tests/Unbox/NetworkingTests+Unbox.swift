import XCTest
import OHHTTPStubs
import Nimble

class UnboxNetworkingTests: XCTestCase {
    private let client = TestClient()

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testSuccessfulRequestForObject() {
        stub(isPath("/song")) { _ in
            return fixture(OHPathForFile("song.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
//            self.client.sendRequest(Song.Resource.getSong) { response in
//                expect(response.result.value?.title) == "Northern Lites"
//            }

            done()
        }
    }
}
