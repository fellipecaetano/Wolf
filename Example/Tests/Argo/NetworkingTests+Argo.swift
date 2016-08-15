import XCTest
import Nimble
import OHHTTPStubs
import Argo
import Wolf

class ArgoNetworkingTests: XCTestCase {
    private let client = TestClient()

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testSuccessfulRequestForObject() {
        stub(isPath("/user")) { _ in
            return fixture(OHPathForFile("user.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(User.Resource.getUser) { response in
                expect(response.result.value?.username) == "fellipecaetano"
                done()
            }
        }
    }

    func testInvalidSchemaObjectRequest() {
        stub(isPath("/user/invalid_schema")) { _ in
            return fixture(OHPathForFile("invalid_user.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(User.Resource.getInvalidSchemaUser) { response in
                expect(response.result.value).to(beNil())
                expect(response.result.error).toNot(beNil())

                switch response.result.error! {
                case .InvalidSchema(let error):
                    let expectedError = DecodeError.TypeMismatch(expected: "String", actual: "Number(1)")
                    expect(error).to(equal(expectedError))
                default:
                    fail()
                }

                done()
            }
        }
    }

    func testInvalidFormatObjectRequest() {
        stub(isPath("/user/invalid_format")) { _ in
            return fixture(OHPathForFile("invalid_json.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(User.Resource.getInvalidFormatUser) { response in
                expect(response.result.value).to(beNil())
                expect(response.result.error).toNot(beNil())

                switch response.result.error! {
                case .InvalidFormat(let error):
                    expect(error).toNot(beNil())
                default:
                    fail()
                }

                done()
            }
        }
    }

    func testSuccessfulRequestForFlatArray() {
        stub(isPath("/users")) { _ in
            return fixture(OHPathForFile("users.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(User.FlatArrayResource.getUsers) { response in
                expect(response.result.value?.count) == 3
                expect(response.result.value?[1].username) == "fellipe.caetano"

                done()
            }
        }
    }

    func testSuccessfulRequestForEnvelopedArray() {
        stub(isPath("/users/enveloped")) { _ in
            return fixture(OHPathForFile("enveloped_users.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(User.EnvelopedArrayResource.getEnvelopedUsers) { response in
                expect(response.result.error).to(beNil())
                expect(response.result.value?.count) == 3
                expect(response.result.value?[1].username) == "fellipe.caetano"

                done()
            }
        }
    }
}
