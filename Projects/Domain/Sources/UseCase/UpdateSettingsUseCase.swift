public struct UpdateSettingsUseCase: Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(pushEnabled: Bool) async throws(ProfileError) -> UserProfile {
        try await userRepository.updateSettings(pushEnabled: pushEnabled)
    }
}
