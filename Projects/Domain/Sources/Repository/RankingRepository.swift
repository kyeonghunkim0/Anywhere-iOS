public protocol RankingRepository: Sendable {
    func fetchUserRanking(period: RankingPeriod) async throws(NetworkError) -> [UserRankItem]
    func fetchMyRank(period: RankingPeriod) async throws(NetworkError) -> MyRank
}
