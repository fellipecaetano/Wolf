import Foundation
import UIKit

extension UICollectionView {
    func register<C: protocol<Reusable, NibLoadable>>(type: C.Type) {
        registerNib(type.nib, forCellWithReuseIdentifier: type.reuseIdentifier)
    }

    func dequeueReusableCell<C: UICollectionViewCell where C: Reusable>(for indexPath: NSIndexPath) -> C {
        guard let cell = dequeueReusableCellWithReuseIdentifier(C.reuseIdentifier,
                                                                forIndexPath: indexPath) as? C else {
            fatalError("Could not dequeue reusable cell identified by \(C.reuseIdentifier): "
                + "cell not registered or of wrong type")
        }
        return cell
    }
}
