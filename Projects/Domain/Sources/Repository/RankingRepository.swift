public protocol RankingRepository: Sendable {
    func fetchUserRanking() async throws(NetworkError) -> [UserRankItem]
    func fetchPlaceRanking() async throws(NetworkError) -> [PlaceRankItem]
    func fetchMyRank() async throws(NetworkError) -> MyRank
}
