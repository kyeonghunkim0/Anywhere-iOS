public protocol MatchRepository: Sendable {
    /// radiusKm를 생략하면 서버 기본값 50km가 적용된다.
    func fetchRandomMatch(
        at coordinate: Coordinate,
        radiusKm: Double?,
        tagId: String?
    ) async throws(MatchError) -> RandomMatch
    /// "여기로 결정" — 후보를 진행 중인 여정으로 확정한다. 기존 여정은 서버가 자동 취소한다.
    func confirmMatch(matchId: String) async throws(MatchError) -> CurrentTrip
    func cancelMatch(matchId: String) async throws(MatchError)
    /// 진행 중인 여정이 없으면 nil.
    func fetchCurrentTrip() async throws(MatchError) -> CurrentTrip?
}
