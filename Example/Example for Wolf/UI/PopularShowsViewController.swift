import UIKit
import Wolf
import IBentifiers

class PopularShowsViewController: UICollectionViewController, Identifiable {
    private var shows: [Show] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }

    private let client = TVGuideClient()

    override func viewDidLoad() {
        super.viewDidLoad()

        client.sendRequest(Show.getPopularShows) { [weak self] response in
            self?.shows = response.result.value ?? []
        }

        collectionView?.register(ShowCollectionViewCell.self)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShowCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.show = shows[indexPath.item]
        return cell
    }
}
