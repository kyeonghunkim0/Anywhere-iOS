public struct FetchRecentFeedUseCase: Sendable {
    private let feedRepository: FeedRepository

    public init(feedRepository: FeedRepository) {
        self.feedRepository = feedRepository
    }

    public func execute(limit: Int? = nil) async throws(NetworkError) -> ActivityFeed {
        try await feedRepository.fetchRecentFeed(limit: limit)
    }
}
