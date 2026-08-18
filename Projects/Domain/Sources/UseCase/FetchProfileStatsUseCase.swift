public struct FetchProfileStatsUseCase: Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws(NetworkError) -> ProfileStats {
        try await userRepository.fetchMyStats()
    }
}
