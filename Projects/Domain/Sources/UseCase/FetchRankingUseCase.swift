public struct FetchUserRankingUseCase: Sendable {
    private let rankingRepository: RankingRepository

    public init(rankingRepository: RankingRepository) {
        self.rankingRepository = rankingRepository
    }

    public func execute() async throws(NetworkError) -> [UserRankItem] {
        try await rankingRepository.fetchUserRanking()
    }
}

public struct FetchPlaceRankingUseCase: Sendable {
    private let rankingRepository: RankingRepository

    public init(rankingRepository: RankingRepository) {
        self.rankingRepository = rankingRepository
    }

    public func execute() async throws(NetworkError) -> [PlaceRankItem] {
        try await rankingRepository.fetchPlaceRanking()
    }
}

public struct FetchMyRankUseCase: Sendable {
    private let rankingRepository: RankingRepository

    public init(rankingRepository: RankingRepository) {
        self.rankingRepository = rankingRepository
    }

    public func execute() async throws(NetworkError) -> MyRank {
        try await rankingRepository.fetchMyRank()
    }
}
