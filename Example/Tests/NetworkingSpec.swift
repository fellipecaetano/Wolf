import Foundation
import Quick
import Nimble
import OHHTTPStubs
import Alamofire
import Argo
import Wolf

class NetworkingSpec: QuickSpec {
    private let client = ExampleClient()

    // swiftlint:disable function_body_length
    override func spec() {
        afterEach {
            OHHTTPStubs.removeAllStubs()
        }

        describe("a HTTPClient sending object requests") {
            describe("when the request is sucessful") {
                stub(isPath("/get/user")) { _ in
                    return fixture(OHPathForFile("user.json", self.dynamicType)!, headers: nil)
                }

                var user: User?
                self.client.sendRequest(User.Resource.getUser) { response in
                    user = response.result.value
                }

                it("responds with a constructed object") {
                    expect(user?.username).toEventually(equal("fellipecaetano"))
                }
            }

            describe("when the JSON is schema-invalid") {
                stub(isPath("/get/invalid_user")) { _ in
                    return fixture(OHPathForFile("invalid_user.json", self.dynamicType)!, headers: nil)
                }

                var user: User?
                var error: JSONResponseError?
                self.client.sendRequest(User.Resource.getInvalidUser) { response in
                    user = response.result.value
                    error = response.result.error
                }

                it("responds with a nil object") {
                    expect(user).toEventually(beNil())
                }

                it("responds with a schema decoding error") {
                    switch error! {
                    case .InvalidSchema(let error):
                        let expectedError = DecodeError.TypeMismatch(expected: "String", actual: "Number(1)")
                        expect(error).toEventually(equal(expectedError))
                    default:
                        fail()
                    }
                }
            }

            describe("when the JSON is format-invalid") {
                stub(isPath("/get/invalid_json")) { _ in
                    return fixture(OHPathForFile("invalid_json.json", self.dynamicType)!, headers: nil)
                }

                var user: User?
                var error: JSONResponseError?
                self.client.sendRequest(User.Resource.getInvalidJSON) { response in
                    user = response.result.value
                    error = response.result.error
                }

                it("responds with a nil object") {
                    expect(user).toEventually(beNil())
                }

                it("responds with a format decoding error") {
                    switch error! {
                    case .InvalidFormat(let error):
                        expect(error).toEventuallyNot(beNil())
                    default:
                        fail()
                    }
                }
            }
        }

        describe("a HTTPClient sending array requests") {
            describe("when the flat request is sucessful") {
                stub(isPath("/get/users")) { _ in
                    return fixture(OHPathForFile("users.json", self.dynamicType)!, headers: nil)
                }

                var users: [User]?
                self.client.sendArrayRequest(User.Resource.getUsers) { response in
                    users = response.result.value
                }

                it("responds with the expected object count") {
                    expect(users?.count).toEventually(equal(3))
                }

                it("responds with the expected objects") {
                    expect(users?[1].username).toEventually(equal("fellipe.caetano"))
                }
            }

            describe("when the enveloped request is sucessful") {
                stub(isPath("/get/enveloped_users")) { _ in
                    return fixture(OHPathForFile("enveloped_users.json", self.dynamicType)!, headers: nil)
                }

                var users: [User]?
                self.client.sendArrayRequest(User.ResourceCollection.getEnvelopedUsers) { response in
                    users = response.result.value
                }

                it("responds with the expected object count") {
                    expect(users?.count).toEventually(equal(3))
                }

                it("responds with the expected objects") {
                    expect(users?[1].username).toEventually(equal("fellipe.caetano"))
                }
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
