public struct UpdateProfileUseCase: Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(nickname: String?) async throws(ProfileError) -> UserProfile {
        try await userRepository.updateProfile(nickname: nickname)
    }
}
