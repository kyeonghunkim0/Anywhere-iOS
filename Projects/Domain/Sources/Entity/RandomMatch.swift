public struct MatchInfo: Sendable, Equatable {
    public let remainingMatches: Int
    public let isDepopulatedBonus: Bool
    public let recommendationQuote: String

    public init(remainingMatches: Int, isDepopulatedBonus: Bool, recommendationQuote: String) {
        self.remainingMatches = remainingMatches
        self.isDepopulatedBonus = isDepopulatedBonus
        self.recommendationQuote = recommendationQuote
    }
}

public struct RandomMatch: Sendable {
    public let place: Place
    public let region: Region
    public let matchInfo: MatchInfo

    public init(place: Place, region: Region, matchInfo: MatchInfo) {
        self.place = place
        self.region = region
        self.matchInfo = matchInfo
    }
}
