import PromiseKit
import XCTest

class CatchableTests: XCTestCase {
    func testFinally() {
        let ex = (expectation(description: ""), expectation(description: ""))

        Promise<Void>(error: Error.dummy).catch { _ in
            ex.0.fulfill()
        }.finally {
            ex.1.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

private enum Error: Swift.Error {
    case dummy
}
