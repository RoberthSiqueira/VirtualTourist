import UIKit

class PhotoAlbumCell: UICollectionViewCell {

    // MARK: - UI

    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "placeholder")
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addViewHierarchy()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {

    }

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
