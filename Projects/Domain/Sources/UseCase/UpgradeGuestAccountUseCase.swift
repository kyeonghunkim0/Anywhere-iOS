/// 게스트 계정에 소셜 로그인을 연결해 정회원으로 전환한다. 스탬프·매칭이력은
/// 같은 User row를 그대로 쓰므로 서버가 보존한다.
public struct UpgradeGuestAccountUseCase: Sendable {
    private let socialAuthenticating: SocialAuthenticating
    private let authRepository: AuthRepository
    private let sessionRepository: SessionRepository

    public init(
        socialAuthenticating: SocialAuthenticating,
        authRepository: AuthRepository,
        sessionRepository: SessionRepository
    ) {
        self.socialAuthenticating = socialAuthenticating
        self.authRepository = authRepository
        self.sessionRepository = sessionRepository
    }

    public func execute(socialType: SocialType) async throws(AuthError) -> AuthSession {
        let credential: SocialCredential
        do {
            credential = try await socialAuthenticating.signIn(with: socialType)
        } catch {
            switch error {
            case .cancelled:
                throw AuthError.signInCancelled
            case .failed:
                throw AuthError.socialSignInFailed
            }
        }

        let session = try await authRepository.upgradeGuest(with: credential)
        await sessionRepository.saveToken(session.token)
        return session
    }
}
