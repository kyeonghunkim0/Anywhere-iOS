import Domain

final class RankingRepositoryImpl: RankingRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchUserRanking() async throws(NetworkError) -> [UserRankItem] {
        do {
            let envelope = try await httpClient.request(RankingAPI.users, as: APIResponse<[UserRankItemDTO]>.self)
            return envelope.value.data.map { $0.toEntity() }
        } catch {
            throw ErrorMapper.network(error)
        }
    }

    func fetchPlaceRanking() async throws(NetworkError) -> [PlaceRankItem] {
        do {
            let envelope = try await httpClient.request(RankingAPI.places, as: APIResponse<[PlaceRankItemDTO]>.self)
            return envelope.value.data.map { $0.toEntity() }
        } catch {
            throw ErrorMapper.network(error)
        }
    }

    func fetchMyRank() async throws(NetworkError) -> MyRank {
        do {
            let envelope = try await httpClient.request(RankingAPI.me, as: APIResponse<MyRankDTO>.self)
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
