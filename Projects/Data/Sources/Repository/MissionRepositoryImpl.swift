import Domain

final class MissionRepositoryImpl: MissionRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func checkIn(placeId: String, at coordinate: Coordinate) async throws(CheckInError) -> CheckInResult {
        let request = CheckInRequestDTO(placeId: placeId, lat: coordinate.latitude, lng: coordinate.longitude)
        let body: CheckInResponseDTO
        do {
            body = try await httpClient.request(MissionAPI.checkIn(request), as: CheckInResponseDTO.self).value
        } catch {
            throw ErrorMapper.checkIn(error)
        }

        // 반경 이탈·중복 체크인은 HTTP 400으로 오지만, 서버가 성공 코드에 success:false를
        // 실어 보내는 경로도 열려 있어 본문으로 한 번 더 확인한다.
        guard body.success, let stamp = body.stamp else {
            throw .rejected(message: body.message)
        }

        return CheckInResult(
            message: body.message,
            stamp: stamp.toEntity(),
            newBadges: (body.newBadges ?? []).map { $0.toEntity() }
        )
    }
}
