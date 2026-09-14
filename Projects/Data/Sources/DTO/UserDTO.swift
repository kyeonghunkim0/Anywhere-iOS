import Foundation

/// POST /api/auth/login, /api/auth/guest, /api/auth/guest/upgrade의 data.user.
/// 게스트 계정 전용 필드(isGuest, guestExpiresAt)는 이 엔드포인트에만 있고
/// GET /api/users/me 등에는 없어서 디코딩하지 않는다 — `socialType == "guest"`로 판별한다.
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
    /// 해당 지역의 기초자치단체(REGION) 뱃지. 등록된 뱃지가 없으면 nil.
    let badge: RegionBadgeDTO?
}

/// GET /api/users/me/blocks의 배열 원소.
struct BlockedUserDTO: Decodable, Sendable {
    let id: String
    let nickname: String
    let profileImage: String?
    let blockedAt: Date
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
