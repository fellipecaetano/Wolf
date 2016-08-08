import XCTest
import Wolf
import Nimble

class ArchivePersistenceTests: XCTestCase {
    func testSuccessfulArchiving() {
        testSuccessfulArchiving(token: "main_queue")
    }

    func testSuccessfulArchivingInAnotherQueue() {
        testSuccessfulArchiving(token: "background_queue",
                                queue: dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0))
    }

    private func testSuccessfulArchiving(token token: String, queue: dispatch_queue_t = dispatch_get_main_queue()) {
        let archiving = MockArchiving<TestPersistable>(queue: queue)
        let persistable = TestPersistable(token: token)

        waitUntil { done in
            archiving.archive(persistable).onSuccess { _ in
                let archived = archiving.archivedObjects["file:///test"]
                expect(archived?.token) == persistable.token
                done()
            }
        }
    }

    func testErrorHandlingWhenArchivingFails() {
        let archiving = FailableArchiving<TestPersistable>(queue: dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))

        waitUntil { done in
            archiving.archive(TestPersistable(token: "")).onFailure { error in
                expect(error) == ArchivingError.FailedArchiving
                done()
            }
        }
    }

    func testSuccessfulUnarchiving() {
        waitUntil { done in
            done()
        }
    }
}

private class MockArchiving<T>: Archiving, Asynchronous {
    var archivedObjects: [String: T] = [:]
    let queue: dispatch_queue_t

    init (queue: dispatch_queue_t = dispatch_get_main_queue()) {
        self.queue = queue
    }

    func archive(rootObject: T, toFile path: String) -> Bool {
        archivedObjects[path] = rootObject
        return true
    }
}

private struct FailableArchiving<T>: Archiving, Asynchronous {
    let queue: dispatch_queue_t

    private func archive(rootObject: T, toFile path: String) -> Bool {
        return false
    }
}

private struct TestPersistable: Persistable, File {
    let token: String

    private var baseURL: NSURL {
        return NSURL(string: "file:///")!
    }

    private var path: String {
        return "test"
    }
}
