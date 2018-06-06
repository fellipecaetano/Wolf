import Foundation
import UIKit

public protocol NibLoadable {
    static var name: String { get }
    static var bundle: Bundle? { get }
}

public extension NibLoadable {
    static var name: String {
        return String(describing: self)
    }

    static var bundle: Bundle? {
        return nil
    }

    static var nib: UINib {
        return UINib(nibName: self.name, bundle: self.bundle)
    }

    static func loadFirst(owner: AnyObject? = nil, options: [AnyHashable: Any]? = nil) -> Self {
        guard let fromNib = nib.instantiate(withOwner: owner, options: options).first else {
            fatalError("The .nib named \(name) is empty")
        }
        guard let typedObject = fromNib as? Self else {
            fatalError("Expected the first object of .nib named \(name) to be of type \(self) but actual type is \(fromNib.self)")
        }
        return typedObject
    }
}
