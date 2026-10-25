import Foundation
import CoreLocation

public final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = LocationManager()

    private let manager = CLLocationManager()
    @Published public var currentLocation: CLLocationCoordinate2D?
    @Published public var currentElevation: Double?
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = 1.0 // update every 1 meter
    }

    public func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        currentLocation = loc.coordinate
        currentElevation = loc.altitude
    }
}
