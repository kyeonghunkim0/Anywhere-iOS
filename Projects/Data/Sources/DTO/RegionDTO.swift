struct RegionDTO: Decodable, Sendable {
    let id: String
    let sidoName: String
    let sigunguName: String
    let isDepopulated: Bool
}

struct RegionBadgeDTO: Decodable, Sendable {
    let key: String
    let name: String
    let description: String
    /// 완전한 이미지 URL로 온다.
    let icon: String
}

/// GET /api/regions/growth.
struct GrowthRegionDTO: Decodable, Sendable {
    let regionId: String
    let sidoName: String
    let sigunguName: String
    let isDepopulated: Bool
    let level: Int
    let current: Int
    let target: Int
    let remaining: Int
    let badge: RegionBadgeDTO?
}

struct RegionLevelRowDTO: Decodable, Sendable {
    let level: Int
    let label: String
    let reward: String
    let achieved: Bool
}

/// GET /api/regions/{regionId}.
struct RegionDetailDTO: Decodable, Sendable {
    let regionId: String
    let sidoName: String
    let sigunguName: String
    let isDepopulated: Bool
    let level: Int
    let current: Int
    /// 최고 레벨 달성 시 null.
    let target: Int?
    let progressLabel: String
    let remainLabel: String
    let quote: String?
    let imageUrl: String?
    let imageCredit: String?
    let badge: RegionBadgeDTO?
    let stats: [LabeledValueDTO]
    let levels: [RegionLevelRowDTO]
}
