import Domain

final class SearchRepositoryImpl: SearchRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func search(query: String, limit: Int?, offset: Int?) async throws(NetworkError) -> SearchResult {
        do {
            let envelope = try await httpClient.request(
                SearchAPI.search(query: query, limit: limit, offset: offset),
                as: APIResponse<SearchResultDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
