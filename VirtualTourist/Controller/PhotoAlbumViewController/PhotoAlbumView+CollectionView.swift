import UIKit

extension PhotoAlbumView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photos.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        delegate?.didTapPhotoToDelete(from: indexPath)
    }
}

extension PhotoAlbumView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoAlbumCell else {
            return UICollectionViewCell()
        }

        let photo = photos[indexPath.row]
        cell.setupCell(with: photo)
        return cell
    }
}

