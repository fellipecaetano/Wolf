import XCTest
import Wolf
import Nimble

class ArchivingTests: XCTestCase {
    func testSuccessfulArchiving() {
        testSuccessfulArchiving(token: "main_queue")
    }

    func testSuccessfulArchivingInAnotherQueue() {
        testSuccessfulArchiving(token: "background_queue",
                                queue: dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0))
    }

    private func testSuccessfulArchiving(token token: String, queue: dispatch_queue_t = dispatch_get_main_queue()) {
        let archiving = MockArchiving<TestFile>(queue: queue)
        let persistable = TestFile(token: token)

        waitUntil { done in
            archiving.archive(persistable).onSuccess { _ in
                let archived = archiving.archivedObjects[persistable.URL.absoluteString]
                expect(archived?.token) == persistable.token
                done()
            }
        }
    }

    func testErrorHandlingWhenArchivingFails() {
        let archiving = FailableArchiving<TestFile>(queue: dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))

        waitUntil { done in
            archiving.archive(TestFile(token: "")).onFailure { error in
                expect(error) == ArchivingError.FailedWriting
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

private class MockArchiving<T: URLConvertible>: Archiving, Asynchronous {
    var archivedObjects: [String: T] = [:]
    let queue: dispatch_queue_t

    init (queue: dispatch_queue_t = dispatch_get_main_queue()) {
        self.queue = queue
    }

    func archive(rootObject: T) -> Bool {
        archivedObjects[rootObject.URL.absoluteString] = rootObject
        return true
    }
}

private struct FailableArchiving<T>: Archiving, Asynchronous {
    let queue: dispatch_queue_t

    private func archive(rootObject: T) -> Bool {
        return false
    }
}

private struct TestFile: URLConvertible {
    let token: String

    private var baseURL: NSURL {
        return NSURL(string: "file:///")!
    }

    private var path: String {
        return "test"
    }
}
