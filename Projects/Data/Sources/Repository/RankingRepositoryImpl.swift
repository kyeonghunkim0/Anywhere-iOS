import Domain
final class RankingRepositoryImpl: RankingRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchUserRanking(period: RankingPeriod) async throws(NetworkError) -> [UserRankItem] {
        do {
            let envelope = try await httpClient.request(
                RankingAPI.users(period: period.rawValue),
                as: RankingResponseDTO<[UserRankItemDTO]>.self
            )
            return envelope.value.data.map { $0.toEntity() }
        } catch {
            throw ErrorMapper.network(error)
        }
    }

    func fetchMyRank(period: RankingPeriod) async throws(NetworkError) -> MyRank {
        do {
            let envelope = try await httpClient.request(
                RankingAPI.me(period: period.rawValue),
                as: RankingResponseDTO<MyRankDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
