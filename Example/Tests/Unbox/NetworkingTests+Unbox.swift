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
            self.client.sendRequest(Song.Resource.getSong) { response in
                expect(response.result.value?.title) == "Northern Lites"
                done()
            }
        }
    }

    func testSuccessfulRequestForArray() {
        stub(isPath("/songs")) { _ in
            return fixture(OHPathForFile("songs.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendArrayRequest(Song.Resource.getSongs) { response in
                expect(response.result.value?.count) == 4
                expect(response.result.value?[2].title) == "The Placid Casual"
                done()
            }
        }
    }
}
