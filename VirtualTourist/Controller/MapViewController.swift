import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - Properties

    let mapView = MapView(frame: .zero)

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()

        mapView.setupView()
        mapView.delegate = self
        view = mapView

        requestLocation(with: .zero, and: .zero)
    }

    // MARK: - Methods

    private func setupNavigation() {
        navigationItem.title = "Choose a location"
    }

    private func requestLocation(with latitude: Double, and longitude: Double) {
        mapView.requestingData()
        mapView.dataRequested()
    }

    private func createAnnotation(latitude: Double, longitude: Double) {
        var annotations: [MKAnnotation] = []

        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)


        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotations.append(annotation)
        mapView.setupAnnotation(annotation: annotation)
    }
}

extension MapViewController: MapViewDelegate {}
