import UIKit

class PhotoAlbumViewController: UIViewController {

    // MARK: - Properties
    var lat: Double?
    var long: Double?
    let photoAlbumView = PhotoAlbumView(frame: .zero)

    private let flickrClient = FlickrClient.shared

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        photoAlbumView.setupView()
        photoAlbumView.delegate = self
        view = photoAlbumView

        fillAlbum(isNewCollection: false)
    }

    // MARK: - Methods

    private func fillAlbum(isNewCollection: Bool) {
        guard let lat = lat, let long = long else { return }
        flickrClient.getAlbum(lat: lat, long: long, isNewCollection: isNewCollection, completion: handleGETAlbum(photos:error:))
    }

    private func handleGETAlbum(photos: [Photo], error: Error?) {
        if error == nil && !photos.isEmpty {
            photoAlbumView.reloadPhotos(with: photos)
        } else {
            photoAlbumView.noImagesState()
        }
    }
}

extension PhotoAlbumViewController: PhotoAlbumViewDelegate {
    func didTapNewAlbum() {
        fillAlbum(isNewCollection: true)
    }
}
