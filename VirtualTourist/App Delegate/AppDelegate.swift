import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        loadRegionStore()
        return true
    }

    private func loadRegionStore() {
        let regionStore = RegionStore.shared
        regionStore.load()
    }
}

