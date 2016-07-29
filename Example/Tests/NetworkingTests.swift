import Foundation
import XCTest
import Nimble
import OHHTTPStubs
import Alamofire
import Argo
import Wolf

class NetworkingTests: XCTestCase {
    private let client = ExampleClient()

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testSuccessfulRequestForObject() {
        stub(isPath("/get/user")) { _ in
            return fixture(OHPathForFile("user.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(User.Resource.getUser) { response in
                expect(response.result.value?.username).to(equal("fellipecaetano"))
                done()
            }
        }
    }

    func testRequestForJSONWithInvalidSchema() {
        stub(isPath("/get/invalid_user")) { _ in
            return fixture(OHPathForFile("invalid_user.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(User.Resource.getInvalidUser) { response in
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

    func testRequestForJSONWithInvalidFormat() {
        stub(isPath("/get/invalid_json")) { _ in
            return fixture(OHPathForFile("invalid_json.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendRequest(User.Resource.getInvalidJSON) { response in
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
        stub(isPath("/get/users")) { _ in
            return fixture(OHPathForFile("users.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendArrayRequest(User.Resource.getUsers) { response in
                expect(response.result.value?.count).to(equal(3))
                expect(response.result.value?[1].username).to(equal("fellipe.caetano"))

                done()
            }
        }
    }

    func testSuccessfulRequestForEnvelopedArray() {
        stub(isPath("/get/enveloped_users")) { _ in
            return fixture(OHPathForFile("enveloped_users.json", self.dynamicType)!, headers: nil)
        }

        waitUntil { done in
            self.client.sendArrayRequest(User.ResourceCollection.getEnvelopedUsers) { response in
                expect(response.result.value?.count).to(equal(3))
                expect(response.result.value?[1].username).to(equal("fellipe.caetano"))

                done()
            }
        }
    }
}

private class ExampleClient: HTTPClient {
    var baseURL: NSURL {
        return NSURL(string: "http://example.com")!
    }

    let manager: Manager

    init() {
        manager = Manager()
    }
}

private struct User {
    let username: String
}

extension User: Decodable {
    static func decode(json: JSON) -> Decoded<User> {
        return self.init
            <^> json <| "username"
    }
}

extension User {
    enum Resource: HTTPResource {
        typealias Value = User

        case getUser
        case getInvalidUser
        case getInvalidJSON
        case getUsers

        var path: String {
            switch self {
            case .getUser:
                return "get/user"

            case .getInvalidUser:
                return "get/invalid_user"

            case .getInvalidJSON:
                return "get/invalid_json"

            case .getUsers:
                return "get/users"
            }
        }
    }

    enum ResourceCollection: HTTPResource, JSONEnvelope {
        typealias Value = User

        case getEnvelopedUsers

        var path: String {
            switch self {
            case .getEnvelopedUsers:
                return "get/enveloped_users"
            }
        }

        var rootKey: String? {
            return "users"
        }
    }
}
