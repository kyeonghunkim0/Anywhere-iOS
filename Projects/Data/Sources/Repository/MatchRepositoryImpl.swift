import Domain

final class MatchRepositoryImpl: MatchRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchRandomMatch(
        at coordinate: Coordinate,
        radiusKm: Double?,
        tagId: String?
    ) async throws(MatchError) -> RandomMatch {
        do {
            let envelope = try await httpClient.request(
                MatchAPI.random(
                    lat: coordinate.latitude,
                    lng: coordinate.longitude,
                    radiusKm: radiusKm,
                    tagId: tagId
                ),
                as: APIResponse<MatchDataDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.match(error)
        }
    }

    func confirmMatch(matchId: String) async throws(MatchError) -> CurrentTrip {
        do {
            let envelope = try await httpClient.request(
                MatchAPI.confirm(matchId: matchId),
                as: APIResponse<CurrentTripDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.match(error)
        }
    }

    func cancelMatch(matchId: String) async throws(MatchError) {
        do {
            _ = try await httpClient.request(MatchAPI.cancel(matchId: matchId), as: MessageResponse.self)
        } catch {
            throw ErrorMapper.match(error)
        }
    }

    func fetchCurrentTrip() async throws(MatchError) -> CurrentTrip? {
        do {
            // 진행 중인 여정이 없으면 서버가 data: null을 준다.
            let envelope = try await httpClient.request(MatchAPI.current, as: APIResponse<CurrentTripDTO?>.self)
            return envelope.value.data?.toEntity()
        } catch {
            throw ErrorMapper.match(error)
        }
    }
}
