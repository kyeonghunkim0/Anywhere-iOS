import Foundation

struct PassportRegionDTO: Decodable, Sendable {
    let regionId: String
    let sidoName: String
    let sigunguName: String
    let isDepopulated: Bool
    let isVisited: Bool
    let visitCount: Int
    let lastVisitedAt: Date?
    let visitorOrder: Int?
}

struct BadgeCollectionItemDTO: Decodable, Sendable {
    let id: String
    let title: String
    let description: String
    let type: String
    let imageUrl: String?
    let isAcquired: Bool
    let acquiredAt: Date?
    let visitorOrder: Int?
    let visitorOrderMessage: String
}

struct StampEngravingDTO: Decodable, Sendable {
    let id: String
    let placeName: String
    let regionName: String
    let isDepopulated: Bool
    let visitorOrder: Int
    let engravingText: String
    let checkedInAt: Date
}

struct PassportUserDTO: Decodable, Sendable {
    let id: String
    let nickname: String
    let profileImage: String?
    let level: Int
    let exp: Int
    let totalStamps: Int
    let totalDistanceKm: Double
}

struct PassportContributionDTO: Decodable, Sendable {
    let totalVisitedRegions: Int
    let depopulatedVisitedCount: Int
    let depopulatedRatioPercent: Int
    let topPercentileText: String
}

struct PassportDTO: Decodable, Sendable {
    let user: PassportUserDTO
    let contribution: PassportContributionDTO
    let completionRate: Double
    let badgeCollection: [BadgeCollectionItemDTO]
    let stampEngravings: [StampEngravingDTO]
    let regions: [PassportRegionDTO]
}
