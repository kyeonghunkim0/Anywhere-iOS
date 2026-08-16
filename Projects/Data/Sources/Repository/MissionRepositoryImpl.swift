import Domain
final class MissionRepositoryImpl: MissionRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func checkIn(placeId: String, at coordinate: Coordinate) async throws(CheckInError) -> CheckInResult {
        let request = CheckInRequestDTO(placeId: placeId, lat: coordinate.latitude, lng: coordinate.longitude)
        do {
            let envelope = try await httpClient.request(MissionAPI.checkIn(request), as: CheckInResponseDTO.self)
            return CheckInResult(message: envelope.value.message, stamp: envelope.value.stamp.toEntity())
        } catch {
            throw ErrorMapper.checkIn(error)
        }
    }
}
