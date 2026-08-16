public struct RestoreSessionUseCase: Sendable {
    private let sessionRepository: SessionRepository
    private let authRepository: AuthRepository

    public init(sessionRepository: SessionRepository, authRepository: AuthRepository) {
        self.sessionRepository = sessionRepository
        self.authRepository = authRepository
    }

    /// 저장된 토큰이 없거나 만료된 경우 nil을 반환하고 토큰을 정리한다.
    public func execute() async -> UserProfile? {
        guard let token = await sessionRepository.currentToken(), !token.isEmpty else { return nil }
        do {
            return try await authRepository.fetchMyProfile()
        } catch {
            if case .sessionExpired = error {
                await sessionRepository.clearToken()
            }
            return nil
        }
    }
}
