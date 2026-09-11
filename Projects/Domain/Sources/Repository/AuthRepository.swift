public protocol AuthRepository: Sendable {
    func login(with credential: SocialCredential) async throws(AuthError) -> AuthSession
    func loginAsGuest(deviceId: String) async throws(AuthError) -> AuthSession
    /// 게스트 토큰으로 인증된 상태에서 소셜 계정을 연결해 같은 User row를 정회원으로 전환한다.
    func upgradeGuest(with credential: SocialCredential) async throws(AuthError) -> AuthSession
}
