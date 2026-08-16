public enum QuestError: Error, Sendable {
    /// HTTP 400. "존재하지 않음" / "만료됨" / "이미 수집함" / "반경 이탈" 등.
    case rejected(message: String)
    case network(NetworkError)
}
