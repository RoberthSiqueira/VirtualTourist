import CoreData
import Foundation

class DataController {

    static let shared = DataController(modelName: "VirtualTourist")

    // MARK: Properties

    private let persistendContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        return persistendContainer.viewContext
    }

    // MARK: INIT

    private init(modelName: String) {
        persistendContainer = NSPersistentContainer(name: modelName)
    }

    // MARK: API

    func load(completion: (() -> Void)? = nil) {
        persistendContainer.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
