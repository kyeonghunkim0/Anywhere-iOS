struct HomeSectionVisibilityDTO: Decodable, Sendable {
    let specialQuests: Bool
    let trendingLocal: Bool
}

/// GET /api/home.
struct HomeSnapshotDTO: Decodable, Sendable {
    let currentTrip: CurrentTripDTO?
    let seasonalBadges: [BadgeDTO]
    let growthRegions: [GrowthRegionDTO]
    let sectionVisibility: HomeSectionVisibilityDTO
}
