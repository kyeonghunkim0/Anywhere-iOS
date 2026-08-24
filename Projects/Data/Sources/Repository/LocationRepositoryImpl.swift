import CoreLocation
import Domain

/// CLLocationManagerDelegate 콜백이 어느 스레드로 오는지 문서상 보장되지 않아
/// continuation 저장 프로퍼티를 직접 잠그지 않는다. @unchecked Sendable로 표시하고
/// 대신 delegate 콜백에서만 저장 프로퍼티를 건드리도록 좁게 유지한다.
final class LocationRepositoryImpl: NSObject, LocationRepository, CLLocationManagerDelegate, @unchecked Sendable {
    private let manager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<LocationAuthorization, Never>?
    private var locationContinuation: CheckedContinuation<Coordinate, Error>?

    /// 최근 좌표를 그대로 쓸 수 있는 시간. 이 앱이 좌표를 쓰는 두 곳 모두
    /// 이 정도 오차를 견딘다 — 매칭은 반경 100km 단위로 고르고,
    /// 도착 인증은 서버가 500m로 판정한다.
    private static let acceptableAge: TimeInterval = 60

    override init() {
        super.init()
        manager.delegate = self
        // 기본값(Best)은 GPS 픽스를 기다리느라 실내에서 수 초가 걸린다.
        // 이 앱에 미터 단위 정밀도가 필요한 기능은 없다.
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
        // 권한을 먼저 확보한다. .notDetermined 상태로 requestLocation()을 부르면
        // iOS는 다이얼로그를 띄우지 않고 그대로 실패시킨다.
        switch await requestAuthorization() {
        case .authorized:
            break
        case .notDetermined, .denied, .restricted:
            throw .authorizationDenied
        }

        // 최근에 잡아둔 좌표가 있으면 새 픽스를 기다리지 않는다.
        if let cached = manager.location,
           Date().timeIntervalSince(cached.timestamp) < Self.acceptableAge,
           cached.horizontalAccuracy >= 0 {
            return Coordinate(
                latitude: cached.coordinate.latitude,
                longitude: cached.coordinate.longitude
            )
        }

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
