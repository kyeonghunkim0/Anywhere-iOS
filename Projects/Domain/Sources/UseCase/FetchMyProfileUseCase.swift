public struct FetchMyProfileUseCase: Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws(AuthError) -> UserProfile {
        try await userRepository.fetchMyProfile()
    }
}
