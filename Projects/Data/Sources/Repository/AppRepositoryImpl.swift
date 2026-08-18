import Domain

final class AppRepositoryImpl: AppRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchAppInfo(version: String?) async throws(NetworkError) -> AppInfo {
        do {
            let envelope = try await httpClient.request(
                AppAPI.info(version: version),
                as: APIResponse<AppInfoDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
