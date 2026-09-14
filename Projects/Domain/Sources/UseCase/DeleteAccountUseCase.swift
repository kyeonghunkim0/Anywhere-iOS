/// 서버에 탈퇴를 요청한 뒤 로컬 세션도 정리한다. 순서가 바뀌면(먼저 토큰을 지우면)
/// 탈퇴 요청 자체가 인증 실패로 막힌다.
public struct DeleteAccountUseCase: Sendable {
    private let userRepository: UserRepository
    private let socialAuthenticating: SocialAuthenticating
    private let sessionRepository: SessionRepository

    public init(
        userRepository: UserRepository,
        socialAuthenticating: SocialAuthenticating,
        sessionRepository: SessionRepository
    ) {
        self.userRepository = userRepository
        self.socialAuthenticating = socialAuthenticating
        self.sessionRepository = sessionRepository
    }

    public func execute() async throws(AuthError) {
        try await userRepository.deleteMyAccount()
        await socialAuthenticating.signOut()
        await sessionRepository.clearToken()
    }
}
