/// 이미 권한이 있을 때만 현재 좌표를 돌려준다.
///
/// 권한 다이얼로그를 띄우지 않는 게 요점이다 — 장소 검색은 목록에 거리를
/// 곁들이는 것뿐이라 권한을 조를 자리가 아니고, 권한은 앱을 열 때 한 번 받는다.
/// 권한이 없거나 측위에 실패하면 nil이고, 그러면 화면이 거리를 그리지 않는다.
public struct FetchCurrentLocationUseCase: Sendable {
    private let locationRepository: LocationRepository

    public init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }

    public func execute() async -> Coordinate? {
        guard await locationRepository.authorizationStatus() == .authorized else { return nil }
        return try? await locationRepository.currentCoordinate()
    }
}
