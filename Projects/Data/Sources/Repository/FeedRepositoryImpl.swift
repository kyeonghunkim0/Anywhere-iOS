import Domain

final class FeedRepositoryImpl: FeedRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchRecentFeed(limit: Int?) async throws(NetworkError) -> ActivityFeed {
        do {
            let envelope = try await httpClient.request(
                FeedAPI.recent(limit: limit),
                as: APIResponse<ActivityFeedDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
