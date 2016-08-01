import UIKit
import Wolf

class ShowCollectionViewCell: UICollectionViewCell, NibLoadable, Reusable {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var label: UILabel!
}
