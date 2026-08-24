public struct RequestLocationPermissionUseCase: Sendable {
    private let locationRepository: LocationRepository

    public init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }

    /// 아직 묻지 않았으면 시스템 다이얼로그를 띄우고, 이미 정해졌으면 그 상태를 그대로 돌려준다.
    public func execute() async -> LocationAuthorization {
        await locationRepository.requestAuthorization()
    }
}
