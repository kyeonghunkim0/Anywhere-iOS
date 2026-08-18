public struct FetchRankerDetailUseCase: Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(userId: String) async throws(NetworkError) -> RankerDetail {
        try await userRepository.fetchRankerDetail(userId: userId)
    }
}
