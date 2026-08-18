public enum ProfileError: Error, Sendable {
    /// HTTP 400. 닉네임 길이 제한(12자) 등 서버가 준 사유.
    case rejected(message: String)
    case sessionExpired
    case network(NetworkError)
}
