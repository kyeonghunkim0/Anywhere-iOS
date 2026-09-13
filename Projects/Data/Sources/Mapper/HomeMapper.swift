import Domain

extension HomeSectionVisibilityDTO {
    func toEntity() -> HomeSectionVisibility {
        HomeSectionVisibility(specialQuests: specialQuests, trendingLocal: trendingLocal)
    }
}

extension HomeSnapshotDTO {
    func toEntity() -> HomeSnapshot {
        HomeSnapshot(
            currentTrip: currentTrip?.toEntity(),
            seasonalBadges: seasonalBadges.map { $0.toEntity() },
            growthRegions: growthRegions.map { $0.toEntity() },
            sectionVisibility: sectionVisibility.toEntity()
        )
    }
}
