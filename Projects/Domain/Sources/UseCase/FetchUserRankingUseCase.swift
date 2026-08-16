public struct FetchUserRankingUseCase: Sendable {
    private let rankingRepository: RankingRepository

    public init(rankingRepository: RankingRepository) {
        self.rankingRepository = rankingRepository
    }

    public func execute(period: RankingPeriod) async throws(NetworkError) -> [UserRankItem] {
        try await rankingRepository.fetchUserRanking(period: period)
    }
}
