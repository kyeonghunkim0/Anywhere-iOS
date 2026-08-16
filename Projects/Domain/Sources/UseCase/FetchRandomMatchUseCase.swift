public struct FetchRandomMatchUseCase: Sendable {
    private let locationRepository: LocationRepository
    private let matchRepository: MatchRepository

    public init(locationRepository: LocationRepository, matchRepository: MatchRepository) {
        self.locationRepository = locationRepository
        self.matchRepository = matchRepository
    }

    public func execute(durationFilter: DurationFilter?, tag: String?) async throws(MatchError) -> RandomMatch {
        let coordinate: Coordinate
        do {
            coordinate = try await locationRepository.currentCoordinate()
        } catch {
            throw .network(.unknown)
        }
        return try await matchRepository.fetchRandomMatch(at: coordinate, durationFilter: durationFilter, tag: tag)
    }
}
