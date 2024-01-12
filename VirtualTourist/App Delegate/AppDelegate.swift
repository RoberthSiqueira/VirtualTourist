import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let dataController = DataController.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        loadRegionStore()
        dataController.load()
        return true
    }

    private func loadRegionStore() {
        let regionStore = RegionStore.shared
        regionStore.load()
    }
}

