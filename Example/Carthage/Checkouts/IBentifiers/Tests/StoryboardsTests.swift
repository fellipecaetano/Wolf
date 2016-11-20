import Foundation
import UIKit
import XCTest
import Nimble
import IBentifiers

class StoryboardsTests: XCTestCase {
    func testViewControllerInstantiation() {
        let viewController: TestViewController = Storyboard.Test.instantiateViewController()
        expect(String(describing: type(of: viewController))) == "TestViewController"
    }
}

class TestViewController: UIViewController, Identifiable {}

private enum Storyboard: String, StoryboardConvertible {
    case Test

    fileprivate var bundle: Bundle? {
        return Bundle(for: StoryboardsTests.self)
    }
}
