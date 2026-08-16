public enum LocationError: Error, Sendable {
    case authorizationDenied
    case unableToLocate
}

public protocol LocationRepository: Sendable {
    func authorizationStatus() async -> LocationAuthorization
    /// 아직 결정되지 않은 경우 시스템 권한 다이얼로그를 띄우고 결과를 기다린다.
    func requestAuthorization() async -> LocationAuthorization
    func currentCoordinate() async throws(LocationError) -> Coordinate
}
