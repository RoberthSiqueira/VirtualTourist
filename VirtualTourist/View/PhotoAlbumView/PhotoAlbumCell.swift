import UIKit

class PhotoAlbumCell: UICollectionViewCell {

    // MARK: Properties

    var photo: Data?

    private let flickrClient = FlickrClient.shared

    // MARK: - UI

    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "placeholder")
        return imageView
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addViewHierarchy()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: API

    func setupCell(with photo: Data) {
        self.photo = photo
        fillPhoto()
    }

    // MARK: Methods

    private func fillPhoto() {
        if let imageData = photo {
            DispatchQueue.main.async {
                self.photoImageView.image = UIImage(data: imageData)
                self.setNeedsLayout()
            }
        }
    }

    // MARK: View

    private func addViewHierarchy() {
        contentView.addSubview(photoImageView)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
