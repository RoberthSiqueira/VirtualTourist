import CoreData
import MapKit
import UIKit

class MapViewController: UIViewController {

    // MARK: - Properties

    let mapView = MapView(frame: .zero)

    private let regionStore = RegionStore.shared

    private var viewContext = DataController.shared.viewContext

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()

        mapView.setupView()
        mapView.delegate = self
        view = mapView

        fillLastPosionViwed()
        retrievePins()
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

    private func fillLastPosionViwed() {
        guard let region = regionStore.retrive() else { return }
        let coordinate = CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude)
        let span = MKCoordinateSpan(
            latitudeDelta: region.latitudeDelta,
            longitudeDelta: region.longitudeDelta
        )
        mapView.lastSeen(coordinate: coordinate, span: span)
    }

    private func retrievePins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()

        if let result = try? viewContext.fetch(fetchRequest), !result.isEmpty {
            var annotations: [MKAnnotation] = []

            for pin in result {
                let annotation = MKPointAnnotation()
                let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                annotation.coordinate = coordinate
                annotations.append(annotation)
            }
            
            mapView.addAnnotations(annotations)
        }
    }

    private func handleTapAnnotation(with coordinate: CLLocationCoordinate2D, from location: String) {
        let pin = createPin(coordinate: coordinate)
        goToAlbum(title: location, pin: pin)
        saveContext()
    }

    private func createPin(coordinate: CLLocationCoordinate2D) -> Pin {

        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [coordinate.latitude, coordinate.longitude])
        fetchRequest.predicate = predicate

        if let result = try? viewContext.fetch(fetchRequest), let pin = result.first {
            return pin
        } else {
            let pin = Pin(context: viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            return pin
        }
    }

    private func goToAlbum(title: String, pin: Pin) {
        let photoAlbumVC = PhotoAlbumViewController(pin: pin)
        photoAlbumVC.title = title
        navigationController?.pushViewController(photoAlbumVC, animated: true)
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
}

extension MapViewController: MapViewDelegate {
    func didTapOnAnnotation(with coordinate: CLLocationCoordinate2D, from location: String) {
        handleTapAnnotation(with: coordinate, from: location)
    }

    func persistRegion(_ region: MKCoordinateRegion) {
        persist(region)
    }
}
