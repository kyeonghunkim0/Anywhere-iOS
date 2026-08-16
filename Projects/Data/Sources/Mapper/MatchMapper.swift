import Domain
extension MatchDataDTO {
    func toEntity() -> RandomMatch {
        RandomMatch(
            place: place.toEntity(),
            region: region.toEntity(),
            matchInfo: MatchInfo(
                remainingMatches: matchInfo.remainingMatches,
                isDepopulatedBonus: matchInfo.isDepopulatedBonus,
                recommendationQuote: matchInfo.recommendationQuote
            )
        )
    }
}
