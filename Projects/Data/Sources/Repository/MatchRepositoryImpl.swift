import Domain
final class MatchRepositoryImpl: MatchRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchRandomMatch(
        at coordinate: Coordinate,
        durationFilter: DurationFilter?,
        tag: String?
    ) async throws(MatchError) -> RandomMatch {
        do {
            let envelope = try await httpClient.request(
                MatchAPI.random(
                    lat: coordinate.latitude,
                    lng: coordinate.longitude,
                    durationFilter: durationFilter?.rawValue,
                    tag: tag
                ),
                as: APIResponse<MatchDataDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.match(error)
        }
    }
}
