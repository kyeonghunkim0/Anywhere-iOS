public struct FetchMyRankUseCase: Sendable {
    private let rankingRepository: RankingRepository

    public init(rankingRepository: RankingRepository) {
        self.rankingRepository = rankingRepository
    }

    public func execute(period: RankingPeriod) async throws(NetworkError) -> MyRank {
        try await rankingRepository.fetchMyRank(period: period)
    }
}
