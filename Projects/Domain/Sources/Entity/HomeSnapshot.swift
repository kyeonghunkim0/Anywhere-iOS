/// 홈 화면의 섹션별 노출 여부. 운영자가 어드민에서 직접 켜고 끈다.
public struct HomeSectionVisibility: Sendable, Hashable {
    public let specialQuests: Bool
    public let trendingLocal: Bool

    public init(specialQuests: Bool, trendingLocal: Bool) {
        self.specialQuests = specialQuests
        self.trendingLocal = trendingLocal
    }

    public static let allVisible = HomeSectionVisibility(specialQuests: true, trendingLocal: true)
}

/// GET /api/home — 홈 화면에 필요한 데이터를 한 번에 묶어 내려준다.
public struct HomeSnapshot: Sendable {
    public let currentTrip: CurrentTrip?
    public let seasonalBadges: [Badge]
    public let growthRegions: [GrowthRegion]
    public let sectionVisibility: HomeSectionVisibility

    public init(
        currentTrip: CurrentTrip?,
        seasonalBadges: [Badge],
        growthRegions: [GrowthRegion],
        sectionVisibility: HomeSectionVisibility
    ) {
        self.currentTrip = currentTrip
        self.seasonalBadges = seasonalBadges
        self.growthRegions = growthRegions
        self.sectionVisibility = sectionVisibility
    }
}
