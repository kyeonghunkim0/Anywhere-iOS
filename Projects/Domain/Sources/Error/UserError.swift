public enum UserError: Error, Sendable {
    /// 400/404 등 서버가 준 사유.
    case rejected(message: String)
    /// 409. 이미 차단한 사용자 — 호출부는 이걸 실패가 아니라 "이미 차단됨"으로 취급해도 된다.
    case alreadyBlocked
    case sessionExpired
    case network(NetworkError)
}
