struct MatchInfoDTO: Decodable, Sendable {
    let remainingMatches: Int
    let isDepopulatedBonus: Bool
    let recommendationQuote: String
}

struct MatchDataDTO: Decodable, Sendable {
    let place: PlaceDTO
    let region: RegionDTO
    let matchInfo: MatchInfoDTO
}
