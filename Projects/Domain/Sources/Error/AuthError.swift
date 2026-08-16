public enum AuthError: Error, Sendable {
    case signInCancelled
    case sessionExpired
    /// 400 등 서버가 준 사유를 그대로 담는다.
    case rejected(message: String)
    case network(NetworkError)
}
