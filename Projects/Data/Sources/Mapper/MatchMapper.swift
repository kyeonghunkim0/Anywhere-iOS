import Domain

extension MatchDataDTO {
    func toEntity() -> RandomMatch {
        RandomMatch(
            matchId: matchId,
            place: place.toEntity(),
            distanceKm: place.distanceKm,
            region: region.toEntity(),
            matchInfo: MatchInfo(
                remainingMatches: matchInfo.remainingMatches,
                isDepopulatedBonus: matchInfo.isDepopulatedBonus
            )
        )
    }
}

extension CurrentTripDTO {
    func toEntity() -> CurrentTrip {
        CurrentTrip(
            matchId: matchId,
            distanceKm: distanceKm,
            confirmedAt: confirmedAt,
            place: place.toEntity(),
            region: region.toEntity()
        )
    }
}
