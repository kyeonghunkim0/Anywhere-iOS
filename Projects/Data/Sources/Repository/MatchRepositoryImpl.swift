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
                    radiusKm: DebugMatchOverride.radiusKm ?? radiusKm,
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

/// 테스트용 매칭 반경 고정.
///
/// 좌표는 `DebugLocationOverride`가 고정하므로, 조건 화면에서 무엇을 고르든
/// `GET /api/match/random?lat=37.503&lng=126.793&radiusKm=1`이 나간다.
/// 조건 화면의 반경을 다시 쓰려면 nil로 바꾼다(릴리즈 빌드는 이미 nil이다).
private enum DebugMatchOverride {
#if DEBUG
    static let radiusKm: Double? = 1
#else
    static let radiusKm: Double? = nil
#endif
}
