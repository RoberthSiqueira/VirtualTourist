import UIKit

class PhotoAlbumViewController: UIViewController {

    // MARK: - Properties

    var locationImage: UIImage?
    let photoAlbumView = PhotoAlbumView(frame: .zero)

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        photoAlbumView.setupView(image: locationImage)
        photoAlbumView.delegate = self
        view = photoAlbumView
    }

    // MARK: - Methods
}

extension PhotoAlbumViewController: PhotoAlbumViewDelegate {}
