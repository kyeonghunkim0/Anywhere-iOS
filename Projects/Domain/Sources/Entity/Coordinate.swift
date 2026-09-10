import Foundation

public struct Coordinate: Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// 두 좌표 사이의 대권 거리(km).
    /// 도로 거리가 아니라 직선 거리다 — 실제 주행 거리는 이보다 길다.
    public func distanceKm(to other: Coordinate) -> Double {
        let earthRadiusKm = 6_371.0088
        let lat1 = latitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let deltaLat = (other.latitude - latitude) * .pi / 180
        let deltaLon = (other.longitude - longitude) * .pi / 180

        let haversine =
            sin(deltaLat / 2) * sin(deltaLat / 2)
            + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)

        return 2 * earthRadiusKm * asin(min(1, sqrt(haversine)))
    }
}
