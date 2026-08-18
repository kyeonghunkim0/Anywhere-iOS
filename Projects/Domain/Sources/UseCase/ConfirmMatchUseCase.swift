public struct ConfirmMatchUseCase: Sendable {
    private let matchRepository: MatchRepository

    public init(matchRepository: MatchRepository) {
        self.matchRepository = matchRepository
    }

    public func execute(matchId: String) async throws(MatchError) -> CurrentTrip {
        try await matchRepository.confirmMatch(matchId: matchId)
    }
}
