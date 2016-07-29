import Foundation
import UIKit

public protocol StoryboardConvertible {
    var name: String { get }
    var bundle: NSBundle? { get }
}

public extension StoryboardConvertible {
    var bundle: NSBundle? {
        return nil
    }
}

public extension StoryboardConvertible where Self: RawRepresentable, Self.RawValue == String {
    var name: String {
        return rawValue
    }
}

extension StoryboardConvertible {
    public func instantiateViewController <V: UIViewController where V: Identifiable, V.Identifier == String> () -> V {
        return storyboard.instantiateViewController()
    }

    private var storyboard: UIStoryboard {
        return UIStoryboard(name: name, bundle: bundle)
    }
}

private extension UIStoryboard {
    func instantiateViewController <V: UIViewController where V: Identifiable, V.Identifier == String> () -> V {
        let viewController = instantiateViewControllerWithIdentifier(V.identifier)
        guard let typedViewController = viewController as? V else {
            fatalError("Expected view controller of type \(V.self) but got \(viewController.dynamicType)")
        }
        return typedViewController
    }
}
