import XCTest
import OHHTTPStubs
import Nimble
import Unbox
import Wolf

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

    func testSuccessfulRequestForFlatArray() {
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

    func testSuccessfulRequestForEnvelopedArray() {
        stub(isPath("/songs/enveloped")) { _ in
            return fixture(OHPathForFile("enveloped_songs.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendArrayRequest(Song.EnvelopedResource.getEnvelopedSongs) { response in
                expect(response.result.value?.count) == 4
                expect(response.result.value?[3].title) == "Juxtapozed With U"
                done()
            }
        }
    }

    func testInvalidSchemaObjectRequest() {
        stub(isPath("/songs/invalid_schema")) { _ in
            return fixture(OHPathForFile("invalid_song.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(Song.Resource.getInvalidSchemaSong) { response in
                expect(response.result.value).to(beNil())

                switch response.result.error! {
                case .InvalidSchema:
                    break
                default:
                    fail("Expected \(UnboxResponseError.InvalidSchema) but got \(response.result.error!)")
                }
                done()
            }
        }
    }
}
