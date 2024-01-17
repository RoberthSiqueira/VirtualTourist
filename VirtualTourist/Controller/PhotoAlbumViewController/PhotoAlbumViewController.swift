import CoreData
import UIKit

class PhotoAlbumViewController: UIViewController {

    // MARK: - Properties

    var pin: Pin

    let photoAlbumView = PhotoAlbumView(frame: .zero)

    private var fetchedResultsController: NSFetchedResultsController<PhotoPin>?

    // MARK: - INIT

    init(pin: Pin) {
        self.pin = pin

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
            managedObjectContext: DataController.shared.viewContext,
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

        FlickrClient.shared.getAlbum(
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


    private func saveContext() {
        do {
            try DataController.shared.viewContext.save()
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
            DataController.shared.viewContext.delete(photoToDelete)
            saveContext()
        }
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {}
