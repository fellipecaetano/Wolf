import XCTest
import Foundation
import Nimble
import Wolf
import OHHTTPStubs
#if canImport(OHHTTPStubsSwift)
import OHHTTPStubsSwift
#endif

class UnboxNetworkingTests: XCTestCase {
    private let client = TestClient()
    private var cache: [String: URL] = [:]

    override func tearDown() {
        HTTPStubs.removeAllStubs()
    }

    func testSuccessfulRequestForObject() {
        _ = stub(condition: isPath("/song")) { _ in
            return fixture(filePath: GetPathForFile("song.json", type(of: self)), headers: nil)
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
            return fixture(filePath: GetPathForFile("songs.json", type(of: self)), headers: nil)
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
            return fixture(filePath: GetPathForFile("enveloped_songs.json", type(of: self)), headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(Song.EnvelopedArrayResource.getEnvelopedSongs) { response in
                expect(response.result.value?.count) == 4
                expect(response.result.value?[3].title) == "Juxtapozed With U"
                done()
            }
        }
    }

    func testResponseWithInvalidStatusCode() {
        _ = stub(condition: isPath("/song")) { _ in
            return HTTPStubsResponse(jsonObject: [:], statusCode: 403, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(Song.Resource.getSong) { response in
                expect(response.result.value).to(beNil())
                expect(response.result.error).toNot(beNil())
                done()
            }
        }
    }

    func testRequestThatFailsCustomValidation() {
        _ = stub(condition: isPath("/song")) { _ in
            return fixture(filePath: GetPathForFile("song.json", type(of: self)), headers: nil)
        }

        waitUntil { done in
            let expected = NSError(domain: "WolfTestErrorDomain", code: 666, userInfo: nil)

            self.client.sendRequest(Song.Resource.getValidatedSong(expected)) { response in
                let actual = response.result.error as NSError?
                expect(actual?.domain) == expected.domain
                expect(actual?.code) == expected.code
                done()
            }
        }
    }

    func testInvalidSchemaObjectRequest() {
        _ = stub(condition: isPath("/songs/invalid_schema")) { _ in
            return fixture(filePath: GetPathForFile("invalid_song.json", type(of: self)), headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(Song.Resource.getInvalidSchemaSong) { response in
                expect(response.result.value).to(beNil())
                expect(response.result.error).toNot(beNil())
                done()
            }
        }
    }
}
