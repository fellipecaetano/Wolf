import Foundation
import UIKit

public extension UICollectionView {
    func register<C: Reusable & NibLoadable>(_ type: C.Type) {
        self.register(type.nib, forCellWithReuseIdentifier: type.reuseIdentifier)
    }

    func dequeueReusableCell<C: UICollectionViewCell>(for indexPath: IndexPath) -> C where C: Reusable {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: C.reuseIdentifier,
                                                                for: indexPath) as? C else {
            fatalError("Could not dequeue reusable cell identified by \(C.reuseIdentifier): "
                + "cell not registered or of wrong type")
        }
        return cell
    }
}
