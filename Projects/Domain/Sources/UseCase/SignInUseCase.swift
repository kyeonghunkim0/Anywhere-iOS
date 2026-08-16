public struct SignInUseCase: Sendable {
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
                throw AuthError.rejected(message: "소셜 로그인에 실패했습니다.")
            }
        }

        let session = try await authRepository.login(with: credential)
        await sessionRepository.saveToken(session.token)
        return session
    }
}
