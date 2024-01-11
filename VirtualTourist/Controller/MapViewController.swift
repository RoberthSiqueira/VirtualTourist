import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - Properties

    let mapView = MapView(frame: .zero)

    private let regionStore = RegionStore.shared

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()

        mapView.setupView()
        mapView.delegate = self
        view = mapView

        mapView.dataRequested()
    }

    // MARK: - Methods

    private func setupNavigation() {
        navigationItem.title = "Choose a location"
    }

    private func persist(_ region: MKCoordinateRegion) {
        let regionToPersistence = Region(
            latitude: region.center.latitude,
            longitude: region.center.longitude,
            latitudeDelta: region.span.latitudeDelta,
            longitudeDelta: region.span.longitudeDelta
        )
        regionStore.save(region: regionToPersistence)
    }

    private func requestLocation(with latitude: Double, and longitude: Double, from location: String) {
        mapView.requestingData()
        goToAlbum(title: location, lat: latitude, long: longitude)
        mapView.dataRequested()
    }

    private func goToAlbum(title: String, lat: Double, long: Double) {
        let photoAlbumVC = PhotoAlbumViewController()
        photoAlbumVC.title = title
        photoAlbumVC.lat = lat
        photoAlbumVC.long = long
        navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
}

extension MapViewController: MapViewDelegate {
    func didTapOnAnnotation(with coordinate: CLLocationCoordinate2D, from location: String) {
        requestLocation(with: coordinate.latitude, and: coordinate.longitude, from: location)
    }

    func persistRegion(_ region: MKCoordinateRegion) {
        persist(region)
    }
}
