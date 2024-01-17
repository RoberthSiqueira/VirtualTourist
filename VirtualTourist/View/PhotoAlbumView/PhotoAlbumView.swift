import UIKit

protocol PhotoAlbumViewDelegate: AnyObject {
    func didTapNewAlbum()
    func didTapPhotoToDelete(from indexPath: IndexPath)
    func itemsOnSections() -> Int
    func setupCell(_ cell: PhotoAlbumCell, indexPath: IndexPath)
}

class PhotoAlbumView: UIView {

    // MARK: - Properties

    weak var delegate: PhotoAlbumViewDelegate?

    // MARK: - UI

    private lazy var noImagesLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Images"
        label.isHidden = true
        return label
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        return activityIndicator
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
        collectionView.register(PhotoAlbumCell.self, forCellWithReuseIdentifier: "PhotoAlbumCell")
        return collectionView
    }()

    private lazy var newAlbumButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("New Album", for: .normal)
        button.addTarget(self, action: #selector(newAlbumAction), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    // MARK: - API

    func setupView() {
        backgroundColor = .white
        addViewHierarchy()
    }

    func requestingData() {
        loadingIndicator.startAnimating()
    }

    func fillImageDataFromCoreData(with photosPin: [PhotoPin]) {
        albumCollectionView.reloadData()
        showCollection(true)
        newAlbumButton.isEnabled = true
        retriviedData()
    }

    func fillImageDataFromCoreData(with photos: [PhotoPin]) {
        self.photos.removeAll()

        photos.forEach { photoPin in
            guard let imageData = photoPin.image else { return }
            self.photos.append(imageData)
        }
        reloadPhotos()
    }

    func noImagesState() {
        retriviedData()
        showCollection(false)
    }

    // MARK: Methods

    private func showCollection(_ show: Bool) {
        albumCollectionView.isHidden = !show
        newAlbumButton.isHidden = !show
        noImagesLabel.isHidden = show
        loadingIndicator.isHidden = show
    }

    private func retriviedData() {
        loadingIndicator.stopAnimating()
    }

    // MARK: View

    private func addViewHierarchy() {
        addSubview(albumCollectionView)
        addSubview(noImagesLabel)
        addSubview(newAlbumButton)
        addSubview(loadingIndicator)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            albumCollectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            albumCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            albumCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            newAlbumButton.topAnchor.constraint(equalTo: albumCollectionView.bottomAnchor),
            newAlbumButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            newAlbumButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            newAlbumButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            noImagesLabel.centerXAnchor.constraint(equalTo: albumCollectionView.centerXAnchor),
            noImagesLabel.centerYAnchor.constraint(equalTo: albumCollectionView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }

    // MARK: - UIActions

    @objc private func newAlbumAction(_ sender: UIButton) {
        delegate?.didTapNewAlbum()
    }
}
