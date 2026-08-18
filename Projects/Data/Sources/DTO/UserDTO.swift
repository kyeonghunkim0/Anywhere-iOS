import Foundation

/// POST /api/auth/login의 data.user.
struct UserDTO: Decodable, Sendable {
    let id: String
    let nickname: String
    let socialType: String
    let totalStamps: Int
}

/// GET/PATCH /api/users/me, PATCH /api/users/me/settings.
struct UserProfileDTO: Decodable, Sendable {
    let id: String
    let nickname: String
    let socialType: String
    let totalStamps: Int
    let profileImage: String?
    let pushEnabled: Bool
    let level: Int
    let levelLabel: String
}

struct RecentStampDTO: Decodable, Sendable {
    let placeName: String
    let regionName: String
    let checkedInAt: Date
}

/// GET /api/users/me/stats.
struct ProfileStatsDTO: Decodable, Sendable {
    let joinedAt: Date
    let collectedRegions: Int
    let totalRegions: Int
    let depopulatedVisitedRegions: Int
    let depopulatedVisitedPercent: Double
    let totalDistanceKm: Double
    let recentStamp: RecentStampDTO?
    let badgeCount: Int
    let reviewCount: Int
    let nationalRank: Int
    let totalUsers: Int
}

struct WeekActivityDTO: Decodable, Sendable {
    let label: String
    let count: Int
}

struct RepresentativeStampDTO: Decodable, Sendable {
    let regionId: String
    let sidoName: String
    let sigunguName: String
    let visitCount: Int
}

/// GET /api/users/{userId}/detail.
struct RankerDetailDTO: Decodable, Sendable {
    let userId: String
    let nickname: String
    let profileImage: String?
    let level: Int
    let levelLabel: String
    let totalStamps: Int
    let dash: [LabeledValueDTO]
    let weeks: [WeekActivityDTO]
    let stamps: [RepresentativeStampDTO]
}
