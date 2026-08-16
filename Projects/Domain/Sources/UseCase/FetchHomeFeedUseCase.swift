public struct FetchHomeFeedUseCase: Sendable {
    private let feedRepository: FeedRepository

    public init(feedRepository: FeedRepository) {
        self.feedRepository = feedRepository
    }

    public func execute() async throws(NetworkError) -> HomeFeed {
        try await feedRepository.fetchHomeFeed()
    }
}
