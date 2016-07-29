import Foundation
import UIKit

protocol StoryboardConvertible {
    var name: String { get }
    var bundle: NSBundle? { get }
}

extension StoryboardConvertible {
    var bundle: NSBundle? {
        return nil
    }
}

extension StoryboardConvertible where Self: RawRepresentable, Self.RawValue == String {
    var name: String {
        return rawValue
    }
}

extension StoryboardConvertible {
    func instantiateViewController <V: UIViewController where V: Identifiable, V.Identifier == String> () -> V {
        return storyboard.instantiateViewController()
    }

    private var storyboard: UIStoryboard {
        return UIStoryboard(name: name, bundle: bundle)
    }
}

extension UIStoryboard {
    func instantiateViewController <V: UIViewController where V: Identifiable, V.Identifier == String> () -> V {
        let viewController = instantiateViewControllerWithIdentifier(V.identifier)
        guard let typedViewController = viewController as? V else {
            fatalError("Expected view controller of type \(V.self) but got \(viewController.dynamicType)")
        }
        return typedViewController
    }
}
