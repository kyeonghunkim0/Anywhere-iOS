import Foundation

struct PassportRegionDTO: Decodable, Sendable {
    let regionId: String
    let sidoName: String
    let sigunguName: String
    let isDepopulated: Bool
    let isVisited: Bool
    let visitCount: Int
    let lastVisitedAt: Date?
    let level: Int
    let visitorNumber: Int?
}

/// GET /api/passport/{userId}.
struct PassportDTO: Decodable, Sendable {
    let userId: String
    let nickname: String
    let totalStamps: Int
    let totalRegions: Int
    let visitedRegions: Int
    let completionRate: Double
    let regions: [PassportRegionDTO]
}
