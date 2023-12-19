import UIKit
import MapKit

protocol MapViewDelegate: AnyObject {
    func didTapOnAnnotation(with coordinate: CLLocationCoordinate2D, from location: String)
}

final class MapView: UIView {

    // MARK: - Properties

    weak var delegate: MapViewDelegate?

    // MARK: - UI

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressedAction))
        return gesture
    }()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        mapView.isMultipleTouchEnabled = true
        mapView.showsCompass = true
        mapView.delegate = self
        mapView.isHidden = true
        mapView.addGestureRecognizer(longPressGesture)
        return mapView
    }()

    // MARK: - API

    func setupView() {
        backgroundColor = .white
        addViewHierarchy()
    }

    func requestingData() {
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
        mapView.isHidden = true
    }

    func dataRequested() {
        loadingIndicator.stopAnimating()
        mapView.isHidden = false
    }

    // MARK: Methods

    private func setupAnnotation(with coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geoDecoder = CLGeocoder()

        geoDecoder.reverseGeocodeLocation(location) { placemarks, error in
            if placemarks?.isEmpty == false && error == nil {
                DispatchQueue.main.async {
                    let placemark = placemarks?.first
                    let city: String = placemark?.locality ?? ""
                    let estate: String = placemark?.administrativeArea ?? ""

                    annotation.title = "\(String(describing: city))" + (!estate.isEmpty ? ", \(estate)" : "")
                    annotation.subtitle = placemark?.country
                }
            }
        }
        mapView.addAnnotation(annotation)
    }

    // MARK: View

    private func addViewHierarchy() {
        addSubview(loadingIndicator)
        addSubview(mapView)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    // MARK: - UIActions

    @objc private func longPressedAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            setupAnnotation(with: coordinate)
        }
    }
}

extension MapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView

        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.markerTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }

        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let annotation = view.annotation,
                let location = annotation.title ?? "" {
                delegate?.didTapOnAnnotation(with: annotation.coordinate, from: location)
            }
        }
    }
}
