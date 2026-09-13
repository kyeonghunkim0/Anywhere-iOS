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
            var match = try await requestRandomMatch(at: coordinate, radiusKm: radiusKm, tagId: tagId)

            // 좁은 반경에서는 같은 장소가 연속으로 나올 수 있다.
            // 남은 매칭 횟수가 있는 동안은 다른 장소가 나올 때까지 자동으로 다시 뽑는다.
            while await match.place.id == RecentMatchCache.shared.lastPlaceId, match.matchInfo.remainingMatches > 0 {
                match = try await requestRandomMatch(at: coordinate, radiusKm: radiusKm, tagId: tagId)
            }

            await RecentMatchCache.shared.remember(match.place.id)
            return match
        } catch {
            throw ErrorMapper.match(error)
        }
    }

    private func requestRandomMatch(
        at coordinate: Coordinate,
        radiusKm: Double?,
        tagId: String?
    ) async throws(TransportError) -> RandomMatch {
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
    }

    func createCustomMatch(placeId: String, at coordinate: Coordinate) async throws(MatchError) -> RandomMatch {
        do {
            let envelope = try await httpClient.request(
                MatchAPI.custom(
                    CustomMatchRequestDTO(placeId: placeId, lat: coordinate.latitude, lng: coordinate.longitude)
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

/// 직전에 받은 랜덤 매칭 장소를 기억해 중복 여부를 판단한다.
/// `MatchRepositoryImpl`은 호출마다 새 인스턴스로 만들어지므로 인스턴스 프로퍼티로는 기억이 유지되지 않는다.
private actor RecentMatchCache {
    static let shared = RecentMatchCache()

    private(set) var lastPlaceId: String?

    func remember(_ placeId: String) {
        lastPlaceId = placeId
    }
}
