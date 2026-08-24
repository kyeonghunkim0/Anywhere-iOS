public enum MatchError: Error, Sendable {
    /// HTTP 429. 하루 3회 제한 초과.
    case dailyLimitExceeded(message: String)
    /// HTTP 404. 반경 내 매칭 가능한 장소가 없거나, 존재하지 않는 매칭 ID.
    case notFound(message: String)
    /// HTTP 400. "취소된 매칭" / "이미 체크인 완료" 등 서버가 준 사유.
    case rejected(message: String)
    case network(NetworkError)
    /// 위치 권한이 없거나 측위에 실패했다. 네트워크 문제와 구분해야 안내가 정확해진다.
    case location(LocationError)
}
