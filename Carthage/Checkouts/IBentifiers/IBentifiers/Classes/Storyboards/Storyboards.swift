import Foundation
import UIKit

public protocol StoryboardConvertible {
    var name: String { get }
    var bundle: Bundle? { get }
}

public extension StoryboardConvertible {
    var bundle: Bundle? {
        return nil
    }
}

public extension StoryboardConvertible where Self: RawRepresentable, Self.RawValue == String {
    var name: String {
        return rawValue
    }
}

extension StoryboardConvertible {
    public func instantiateViewController <V: UIViewController> () -> V where V: Identifiable, V.Identifier == String {
        return storyboard.instantiateViewController()
    }

    fileprivate var storyboard: UIStoryboard {
        return UIStoryboard(name: name, bundle: bundle)
    }
}

private extension UIStoryboard {
    func instantiateViewController <V: UIViewController> () -> V where V: Identifiable, V.Identifier == String {
        let viewController = self.instantiateViewController(withIdentifier: V.identifier)
        guard let typedViewController = viewController as? V else {
            fatalError("Expected view controller of type \(V.self) but got \(type(of: viewController))")
        }
        return typedViewController
    }
}
