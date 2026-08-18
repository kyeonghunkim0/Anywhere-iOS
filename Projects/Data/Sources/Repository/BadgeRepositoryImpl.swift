import Domain

final class BadgeRepositoryImpl: BadgeRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchMyBadges() async throws(NetworkError) -> [Badge] {
        do {
            let envelope = try await httpClient.request(BadgeAPI.mine, as: APIResponse<[BadgeDTO]>.self)
            return envelope.value.data.map { $0.toEntity() }
        } catch {
            throw ErrorMapper.network(error)
        }
    }

    func fetchSeasonalBadges() async throws(NetworkError) -> [Badge] {
        do {
            let envelope = try await httpClient.request(BadgeAPI.seasonal, as: APIResponse<[BadgeDTO]>.self)
            return envelope.value.data.map { $0.toEntity() }
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
