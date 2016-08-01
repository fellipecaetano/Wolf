import Foundation
import UIKit

protocol NibLoadable {
    static var name: String { get }
    static var bundle: NSBundle? { get }
}

extension NibLoadable {
    static var name: String {
        return String(Self)
    }
    
    static var bundle: NSBundle? {
        return nil
    }
    
    static var nib: UINib {
        return UINib(nibName: self.name, bundle: self.bundle)
    }
}
