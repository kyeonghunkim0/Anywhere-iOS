public struct FetchMyProfileUseCase: Sendable {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute() async throws(AuthError) -> UserProfile {
        try await authRepository.fetchMyProfile()
    }
}
