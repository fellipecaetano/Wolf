import Foundation
import UIKit

public extension UITableView {
    func register<C: Reusable & NibLoadable>(_ type: C.Type) {
        self.register(type.nib, forCellReuseIdentifier: type.reuseIdentifier)
    }

    func dequeueReusableCell<C: UITableViewCell>(for indexPath: IndexPath) -> C where C: Reusable {
        guard let cell = self.dequeueReusableCell(withIdentifier: C.reuseIdentifier,
                                                           for: indexPath) as? C else {
            fatalError("Could not dequeue reusable cell identified by \(C.reuseIdentifier): "
                + "cell not registered or of wrong type")
        }
        return cell
    }
}
