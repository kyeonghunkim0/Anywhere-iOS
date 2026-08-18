import Foundation

struct MatchInfoDTO: Decodable, Sendable {
    let remainingMatches: Int
    let isDepopulatedBonus: Bool
}

/// GET /api/match/random.
struct MatchDataDTO: Decodable, Sendable {
    let matchId: String
    let place: MatchedPlaceDTO
    let region: RegionDTO
    let matchInfo: MatchInfoDTO
}

/// GET /api/match/current, POST /api/match/{matchId}/confirm.
struct CurrentTripDTO: Decodable, Sendable {
    let matchId: String
    let distanceKm: Double
    let confirmedAt: Date
    let place: PlaceDTO
    let region: RegionDTO
}
