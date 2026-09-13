import Domain

final class HomeRepositoryImpl: HomeRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchHome() async throws(NetworkError) -> HomeSnapshot {
        do {
            let envelope = try await httpClient.request(HomeAPI.fetch, as: APIResponse<HomeSnapshotDTO>.self)
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
