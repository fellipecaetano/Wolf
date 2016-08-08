import XCTest
import Wolf
import Nimble

class UnarchivingTests: XCTestCase {
    func testSuccessfulAsyncUnarchiving() {
        let unarchiving = SuccessfulUnarchiving(queue: dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0))

        waitUntil { done in
            unarchiving.unarchive().onSuccess { unarchived in
                expect(unarchived) == true
                done()
            }
        }
    }

    func testFailedUnarchiving() {
        let unarchiving = FailableUnarchiving(queue: dispatch_get_main_queue(), error: .WrongType)

        waitUntil { done in
            unarchiving.unarchive().onFailure { error in
                expect(error) == UnarchivingError.WrongType
                done()
            }
        }
    }
}

struct SuccessfulUnarchiving: Unarchiving, Asynchronous {
    typealias Object = Bool
    let queue: dispatch_queue_t

    func unarchive() throws -> Bool {
        return true
    }
}

struct FailableUnarchiving: Unarchiving, Asynchronous {
    typealias Object = Bool
    let queue: dispatch_queue_t
    let error: UnarchivingError

    func unarchive() throws -> Bool {
        throw error
    }
}
