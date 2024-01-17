import CoreData

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
            case .delete:
                guard let indexPath else { return }
                photoAlbumView.deletePhotoOnCollection(indexPath: indexPath)
            default:
                break
        }
    }
}
