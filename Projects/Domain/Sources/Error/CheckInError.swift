public enum CheckInError: Error, Sendable {
    /// HTTP 400. "존재하지 않는 관광지" / "500m 이탈" / "오늘 이미 체크인" 등
    /// 서버가 한글 메시지로만 구분하는 사유를 그대로 담는다.
    case rejected(message: String)
    case network(NetworkError)
}
