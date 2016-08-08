import XCTest
import Wolf
import Nimble

class ArchivePersistenceTests: XCTestCase {
    func testSuccessfulArchiving() {
        let archiving = MockArchiving()
        var persistable = TestPersistable(archiving: archiving)

        waitUntil { done in
            persistable.token = "token"

            persistable.archive().onSuccess { _ in
                let archived = archiving.archivedObjects["file:///Documents/Example/test"] as? NSDictionary
                expect(archived?["token"] as? String) == "token"
                done()
            }
        }
    }
}

private class MockArchiving: Archiving {
    var archivedObjects: [String: AnyObject] = [:]

    func archive(rootObject: AnyObject, toFile path: String) -> Bool {
        archivedObjects[path] = rootObject
        return true
    }
}

private struct TestPersistable: Persistable, Archivable, NSDictionaryConvertible, File {
    let archiving: Archiving
    var dictionary: [String: String]

    init(archiving: Archiving) {
        self.archiving = archiving
        self.dictionary = [:]
    }

    init?(dictionary: NSDictionary) {
        self.archiving = MockArchiving()
        self.dictionary = dictionary as? [String: String] ?? [:]
    }

    var token: String? {
        get {
            return dictionary["token"]
        }
        set {
            dictionary["token"] = newValue
        }
    }

    private func asDictionary() -> NSDictionary {
        return dictionary
    }

    private var baseURL: NSURL {
        return NSURL(string: "file:///Documents/Example")!
    }

    private var path: String {
        return "test"
    }
}
