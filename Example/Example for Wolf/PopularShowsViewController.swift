import UIKit
import Wolf

class PopularShowsViewController: UICollectionViewController, Identifiable {
    override var collectionView: UICollectionView? {
        didSet {
            collectionView?.register(ShowCollectionViewCell)
        }
    }

    private var shows: [Show] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }

    private let client = TVGuideClient()

    override func viewDidLoad() {
        super.viewDidLoad()

        client.sendArrayRequest(Show.getPopularShows) { [weak self] response in
            self?.shows = response.result.value ?? []
        }
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ShowCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.show = shows[indexPath.item]
        return cell
    }
}
