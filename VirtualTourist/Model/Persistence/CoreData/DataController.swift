import CoreData
import Foundation

class DataController {

    static let shared = DataController(modelName: "VirtualTourist")

    // MARK: Properties

    let persistendContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext

    var viewContext: NSManagedObjectContext {
        return persistendContainer.viewContext
    }

    // MARK: INIT

    private init(modelName: String) {
        persistendContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistendContainer.newBackgroundContext()
    }

    // MARK: API

    func setupContext() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true

        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }

    func load(completion: (() -> Void)? = nil) {
        persistendContainer.loadPersistentStores { [weak self] storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self?.setupContext()
            completion?()
        }
    }
}
