public protocol FeedRepository: Sendable {
    /// limit은 1~50. 생략하면 서버 기본값 20.
    func fetchRecentFeed(limit: Int?) async throws(NetworkError) -> ActivityFeed
}
