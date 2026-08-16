public protocol FeedRepository: Sendable {
    func fetchHomeFeed() async throws(NetworkError) -> HomeFeed
}
