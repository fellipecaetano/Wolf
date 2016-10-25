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
        _ = stub(condition: isPath("/song")) { _ in
            return fixture(filePath: OHPathForFile("song.json", type(of: self))!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(Song.Resource.getSong) { response in
                expect(response.result.value?.title) == "Northern Lites"
                done()
            }
        }
    }

    func testSuccessfulRequestForFlatArray() {
        _ = stub(condition: isPath("/songs")) { _ in
            return fixture(filePath: OHPathForFile("songs.json", type(of: self))!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(Song.FlatArrayResource.getSongs) { response in
                expect(response.result.value?.count) == 4
                expect(response.result.value?[2].title) == "The Placid Casual"
                done()
            }
        }
    }

    func testSuccessfulRequestForEnvelopedArray() {
        _ = stub(condition: isPath("/songs/enveloped")) { _ in
            return fixture(filePath: OHPathForFile("enveloped_songs.json", type(of: self))!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(Song.EnvelopedArrayResource.getEnvelopedSongs) { response in
                expect(response.result.value?.count) == 4
                expect(response.result.value?[3].title) == "Juxtapozed With U"
                done()
            }
        }
    }

    func testInvalidSchemaObjectRequest() {
        _ = stub(condition: isPath("/songs/invalid_schema")) { _ in
            return fixture(filePath: OHPathForFile("invalid_song.json", type(of: self))!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(Song.Resource.getInvalidSchemaSong) { response in
                expect(response.result.value).to(beNil())

                switch response.result.error! {
                case UnboxError.missingValue("title"):
                    break
                default:
                    fail("Expected \(UnboxError.missingValue("title")) but got \(response.result.error!)")
                }
                done()
            }
        }
    }
}
