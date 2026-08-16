import Domain
final class FeedRepositoryImpl: FeedRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchHomeFeed() async throws(NetworkError) -> HomeFeed {
        do {
            let envelope = try await httpClient.request(FeedAPI.home, as: APIResponse<HomeFeedDTO>.self)
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
