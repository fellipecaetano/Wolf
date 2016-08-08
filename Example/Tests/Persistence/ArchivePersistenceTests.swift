import XCTest
import Wolf
import Nimble

class ArchivePersistenceTests: XCTestCase {
    func testSuccessfulArchiving() {
        testSuccessfulArchiving(inQueue: dispatch_get_main_queue())
    }

    func testSuccessfulArchivingInAnotherQueue() {
        let queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        testSuccessfulArchiving(inQueue: queue)
    }

    func testSuccessfulArchiving(inQueue queue: dispatch_queue_t) {
        let archiving = MockArchiving()
        var persistable = TestPersistable(archiving: archiving)

        waitUntil { done in
            persistable.willArchive()

            persistable.archive(inQueue: queue).onSuccess { _ in
                let archived = archiving.archivedObjects["file:///Documents/Example/test"] as? NSDictionary
                expect(archived?["token"] as? String) == "token"
                done()
            }
        }
    }

    func testErrorHandlingWhenArchivingFails() {
        let archiving = FailableArchiving()
        var persistable = TestPersistable(archiving: archiving)

        waitUntil { done in
            persistable.willArchive()

            persistable.archive().onFailure { error in
                expect(error) == ArchivingError.FailedArchiving
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

private class FailableArchiving: Archiving {
    private func archive(rootObject: AnyObject, toFile path: String) -> Bool {
        return false
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

    mutating func willArchive() {
        dictionary["token"] = "token"
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
