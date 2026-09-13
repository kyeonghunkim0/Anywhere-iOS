public struct FetchHomeUseCase: Sendable {
    private let homeRepository: HomeRepository

    public init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
    }

    public func execute() async throws(NetworkError) -> HomeSnapshot {
        try await homeRepository.fetchHome()
    }
}
