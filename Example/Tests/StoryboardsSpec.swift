import Foundation
import UIKit
import Quick
import Nimble
import Wolf

class StoryboardsSpec: QuickSpec {
    override func spec() {
        describe("a StoryboardConvertible instantiating view controllers") {
            let viewController: TestViewController = Storyboard.Test.instantiateViewController()

            it("instantiates view controllers of the expected type") {
                expect(String(viewController.dynamicType)).to(equal("TestViewController"))
            }
        }
    }
}

class TestViewController: UIViewController, Identifiable {}

private enum Storyboard: String, StoryboardConvertible {
    case Test

    private var bundle: NSBundle? {
        return NSBundle(forClass: StoryboardsSpec.self)
    }
}
