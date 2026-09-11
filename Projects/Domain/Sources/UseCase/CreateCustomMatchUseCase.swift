public struct CreateCustomMatchUseCase: Sendable {
    private let locationRepository: LocationRepository
    private let matchRepository: MatchRepository

    public init(locationRepository: LocationRepository, matchRepository: MatchRepository) {
        self.locationRepository = locationRepository
        self.matchRepository = matchRepository
    }

    /// 좌표는 UseCase가 직접 확보한다 — 화면은 위치 권한/측위를 몰라도 된다.
    public func execute(placeId: String) async throws(MatchError) -> RandomMatch {
        let coordinate: Coordinate
        do {
            coordinate = try await locationRepository.currentCoordinate()
        } catch {
            throw .location(error)
        }
        return try await matchRepository.createCustomMatch(placeId: placeId, at: coordinate)
    }
}
