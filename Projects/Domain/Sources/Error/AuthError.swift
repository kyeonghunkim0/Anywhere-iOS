public enum AuthError: Error, Sendable {
    case signInCancelled
    case sessionExpired
    /// 소셜 로그인 SDK(Google/Apple) 자체가 실패한 경우. 문구는 Presentation이 로케일에 맞게 채운다.
    case socialSignInFailed
    /// 400 등 서버가 준 사유를 그대로 담는다.
    case rejected(message: String)
    case network(NetworkError)
}
