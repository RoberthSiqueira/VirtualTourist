import CoreData
import UIKit

class PhotoAlbumViewController: UIViewController {

    // MARK: - Properties

    var pin: Pin
    let photoAlbumView = PhotoAlbumView(frame: .zero)

    private let flickrClient = FlickrClient.shared

    private var viewContext = DataController.shared.viewContext

    // MARK: - INIT

    init(pin: Pin) {
        self.pin = pin
        viewContext = DataController.shared.viewContext

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        photoAlbumView.setupView()
        photoAlbumView.delegate = self
        view = photoAlbumView

        retrieveAlbum()
    }

    // MARK: - Methods

    private func retrieveAlbum() {
        let fetchRequest: NSFetchRequest<PhotoPin> = PhotoPin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = []

        if let result = try? viewContext.fetch(fetchRequest), !result.isEmpty {
            photoAlbumView.fillImageDataFromCoreData(with: result)
        } else {
            fillAlbum(isNewCollection: false)
        }
    }

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
            saveContext(with: photo)
        }
    }

    private func saveContext(with photo: Data?) {
        guard let imageData = photo else { return }

        let fetchRequest: NSFetchRequest<PhotoPin> = PhotoPin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = []

        let photoPin = PhotoPin(context: viewContext)
        photoPin.image = imageData
        photoPin.pin = pin

        do {
            try viewContext.save()
        } catch {
            print(error)
        }

    }
}

extension PhotoAlbumViewController: PhotoAlbumViewDelegate {
    func didTapNewAlbum() {
        fillAlbum(isNewCollection: true)
    }
}
