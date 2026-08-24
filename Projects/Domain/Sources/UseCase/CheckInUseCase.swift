public struct CheckInUseCase: Sendable {
    private let locationRepository: LocationRepository
    private let missionRepository: MissionRepository

    public init(locationRepository: LocationRepository, missionRepository: MissionRepository) {
        self.locationRepository = locationRepository
        self.missionRepository = missionRepository
    }

    public func execute(placeId: String) async throws(CheckInError) -> CheckInResult {
        let coordinate: Coordinate
        do {
            coordinate = try await locationRepository.currentCoordinate()
        } catch {
            throw .location(error)
        }
        return try await missionRepository.checkIn(placeId: placeId, at: coordinate)
    }
}
