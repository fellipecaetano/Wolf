import Foundation
import UIKit

extension UITableView {
    func register<C: protocol<Reusable, NibLoadable>>(type: C.Type) {
        registerNib(type.nib, forCellReuseIdentifier: type.reuseIdentifier)
    }

    func dequeueReusableCell<C: UITableViewCell where C: Reusable>(for indexPath: NSIndexPath) -> C {
        guard let cell = dequeueReusableCellWithIdentifier(C.reuseIdentifier,
                                                           forIndexPath: indexPath) as? C else {
            fatalError("Could not dequeue reusable cell identified by \(C.reuseIdentifier): "
                + "cell not registered or of wrong type")
        }
        return cell
    }
}
