import Foundation
import UIKit
import XCTest
import Nimble
import Wolf

class StoryboardsTests: XCTestCase {
    func testViewControllerInstantiation() {
        let viewController: TestViewController = Storyboard.Test.instantiateViewController()
        expect(String(viewController.dynamicType)) == "TestViewController"
    }
}

class TestViewController: UIViewController, Identifiable {}

private enum Storyboard: String, StoryboardConvertible {
    case Test

    private var bundle: NSBundle? {
        return NSBundle(forClass: StoryboardsTests.self)
    }
}
