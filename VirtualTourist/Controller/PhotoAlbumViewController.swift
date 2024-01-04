import UIKit

class PhotoAlbumViewController: UIViewController {

    // MARK: - Properties

    var locationImage: UIImage?
    var lat: Double?
    var long: Double?
    let photoAlbumView = PhotoAlbumView(frame: .zero)

    private let flickrClient = FlickrClient.shared

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        photoAlbumView.setupView(image: locationImage)
        photoAlbumView.delegate = self
        view = photoAlbumView

        fillAlbum()
    }

    // MARK: - Methods

    private func fillAlbum() {
        guard let lat = lat, let long = long else { return }

        flickrClient.getAlbum(lat: lat, long: long) { [weak self] photos, error in
            if error == nil {
                self?.photoAlbumView.reloadPhotos(with: photos)
            } else {
                self?.photoAlbumView.noImagesState()
            }
        }
    }
}

extension PhotoAlbumViewController: PhotoAlbumViewDelegate {}
