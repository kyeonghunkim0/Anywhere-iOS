public struct FetchCurrentTripUseCase: Sendable {
    private let matchRepository: MatchRepository

    public init(matchRepository: MatchRepository) {
        self.matchRepository = matchRepository
    }

    public func execute() async throws(MatchError) -> CurrentTrip? {
        try await matchRepository.fetchCurrentTrip()
    }
}
