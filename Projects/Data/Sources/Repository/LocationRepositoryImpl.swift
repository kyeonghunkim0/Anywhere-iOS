import CoreLocation
import Domain

/// CLLocationManagerDelegate 콜백이 어느 스레드로 오는지 문서상 보장되지 않아
/// continuation 저장 프로퍼티를 직접 잠그지 않는다. @unchecked Sendable로 표시하고
/// 대신 delegate 콜백에서만 저장 프로퍼티를 건드리도록 좁게 유지한다.
final class LocationRepositoryImpl: NSObject, LocationRepository, CLLocationManagerDelegate, @unchecked Sendable {
    private let manager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<LocationAuthorization, Never>?
    private var locationContinuation: CheckedContinuation<Coordinate, Error>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func authorizationStatus() async -> LocationAuthorization {
        Self.map(manager.authorizationStatus)
    }

    func requestAuthorization() async -> LocationAuthorization {
        guard manager.authorizationStatus == .notDetermined else {
            return Self.map(manager.authorizationStatus)
        }
        return await withCheckedContinuation { continuation in
            self.authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    func currentCoordinate() async throws(LocationError) -> Coordinate {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.locationContinuation = continuation
                manager.requestLocation()
            }
        } catch let error as LocationError {
            throw error
        } catch {
            throw .unableToLocate
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationContinuation?.resume(returning: Self.map(manager.authorizationStatus))
        authorizationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationContinuation?.resume(returning: Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ))
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let mapped: LocationError = (error as? CLError)?.code == .denied ? .authorizationDenied : .unableToLocate
        locationContinuation?.resume(throwing: mapped)
        locationContinuation = nil
    }

    private static func map(_ status: CLAuthorizationStatus) -> LocationAuthorization {
        switch status {
        case .notDetermined:
            .notDetermined
        case .authorizedWhenInUse, .authorizedAlways:
            .authorized
        case .denied:
            .denied
        case .restricted:
            .restricted
        @unknown default:
            .denied
        }
    }
}
