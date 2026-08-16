public protocol MatchRepository: Sendable {
    func fetchRandomMatch(
        at coordinate: Coordinate,
        durationFilter: DurationFilter?,
        tag: String?
    ) async throws(MatchError) -> RandomMatch
}
