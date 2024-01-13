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
        DispatchQueue.global().async {
            self.flickrClient.getAlbum(
                lat: self.pin.latitude,
                long: self.pin.longitude,
                isNewCollection: isNewCollection
            ) { [weak self] photos, error in
                if error == nil && !photos.isEmpty {
                    for (index, photo) in photos.enumerated() {
                        let isLast = (index + 1) == photos.count
                        self?.fillPhotosImages(with: photo, isLast: isLast)
                    }
                } else {
                    self?.photoAlbumView.noImagesState()
                }
            }
        }
    }

    private func fillPhotosImages(with photo: Photo, isLast: Bool) {
        flickrClient.getPhoto(serverId: photo.server, photoId: photo.id, secret: photo.secret) { [weak self] data, error in
            self?.handlePhoto(photoData: data, error: error, isLast: isLast)
        }

    }

    private func handlePhoto(photoData: Data?, error: Error?, isLast: Bool) {
        if error == nil, let photo = photoData {
            photoAlbumView.fillImageData(with: photo, isLast: isLast)
        }
    }


    }
}

extension PhotoAlbumViewController: PhotoAlbumViewDelegate {
    func didTapNewAlbum() {
        fillAlbum(isNewCollection: true)
    }
}
