public protocol MissionRepository: Sendable {
    func checkIn(placeId: String, at coordinate: Coordinate) async throws(CheckInError) -> CheckInResult
}
