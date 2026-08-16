public enum MatchError: Error, Sendable {
    /// HTTP 429. 하루 3회 제한 초과.
    case dailyLimitExceeded(message: String)
    /// HTTP 404. 반경 내 매칭 가능한 장소 없음.
    case noPlaceNearby
    case network(NetworkError)
}
