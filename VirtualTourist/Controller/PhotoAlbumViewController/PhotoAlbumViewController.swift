import CoreData
import UIKit

class PhotoAlbumViewController: UIViewController {

    // MARK: - Properties

    var pin: Pin
    let photoAlbumView = PhotoAlbumView(frame: .zero)

    private let flickrClient = FlickrClient.shared

    private var viewContext = DataController.shared.viewContext

    private var fetchedResultsController: NSFetchedResultsController<PhotoPin>?

    // MARK: - INIT

    init(pin: Pin) {
        self.pin = pin
        viewContext = DataController.shared.viewContext

        super.init(nibName: nil, bundle: nil)
        
        setupFetchedResultsViewController()
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }

    // MARK: - Methods

    private func setupFetchedResultsViewController() {
        let fetchRequest: NSFetchRequest<PhotoPin> = PhotoPin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = []

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private func retrieveAlbum() {
        if let result = fetchedResultsController?.fetchedObjects, !result.isEmpty {
            photoAlbumView.fillImageDataFromCoreData(with: result)
        } else {
            fillAlbum(isNewCollection: false)
        }
    }

    private func fillAlbum(isNewCollection: Bool) {
        photoAlbumView.requestingData()

        self.flickrClient.getAlbum(
            lat: pin.latitude,
            long: pin.longitude,
            isNewCollection: isNewCollection,
            completion: handleFillAlbum(with:error:)
        )
    }

    private func handleFillAlbum(with photos: [Photo], error: Error?) {
        if error == nil && !photos.isEmpty {
            for (index, photo) in photos.enumerated() {
                let isLast = (index + 1) == photos.count
                fillPhotosImages(with: photo, isLast: isLast)
            }
        } else {
            photoAlbumView.noImagesState()
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

        let photoPin = PhotoPin(context: viewContext)
        photoPin.image = imageData
        photoPin.pin = pin

        do {
            try viewContext.save()
        } catch {
            print(error)
        }

    }

    private func deleteAllPhotosPin(completion: @escaping () -> Void) {
        if let results = fetchedResultsController?.fetchedObjects {
            results.forEach{ viewContext.delete($0) }
            viewContext.refreshAllObjects()
            
            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
}

extension PhotoAlbumViewController: PhotoAlbumViewDelegate {
    func didTapNewAlbum() {
        deleteAllPhotosPin { [weak self] in
            self?.fillAlbum(isNewCollection: true)
        }
    }

    func didTapPhotoToDelete(from indexPath: IndexPath) {
        if let photoToDelete = fetchedResultsController?.object(at: indexPath) {
            viewContext.delete(photoToDelete)
            try? viewContext.save()
        }
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {}
