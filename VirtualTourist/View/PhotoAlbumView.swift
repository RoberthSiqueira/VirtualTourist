import UIKit

protocol PhotoAlbumViewDelegate: AnyObject {}

class PhotoAlbumView: UIView {

    // MARK: - Properties

    weak var delegate: PhotoAlbumViewDelegate?

    // MARK: - UI

    private lazy var locationImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var collectionFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 120, height: 120)
        return flowLayout
    }()

    private lazy var albumCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionFlowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoAlbumCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()

    private lazy var newAlbumButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("New Album", for: .normal)
        button.addTarget(self, action: #selector(newAlbumAction), for: .touchUpInside)
        return button
    }()

    // MARK: - API

    func setupView(image: UIImage?) {
        backgroundColor = .white
        locationImageView.image = image
        addViewHierarchy()
    }

    func reloadPhotos() {
        albumCollectionView.reloadData()
    }

    // MARK: View

    private func addViewHierarchy() {
        addSubview(locationImageView)
        addSubview(albumCollectionView)
        addSubview(newAlbumButton)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            locationImageView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            locationImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            locationImageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            locationImageView.heightAnchor.constraint(equalToConstant: 150)
        ])

        NSLayoutConstraint.activate([
            albumCollectionView.topAnchor.constraint(equalTo: locationImageView.bottomAnchor),
            albumCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            albumCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            newAlbumButton.topAnchor.constraint(equalTo: albumCollectionView.bottomAnchor),
            newAlbumButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            newAlbumButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            newAlbumButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    // MARK: - UIActions

    @objc private func newAlbumAction(_ sender: UIButton) {
        print(sender)
    }
}

extension PhotoAlbumView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell selected")
    }
}

extension PhotoAlbumView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoAlbumCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}