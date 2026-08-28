import Foundation

/// 서버가 어디서나 함께 내려주는 최소 유저 정보 (POST /api/auth/login).
public struct User: Sendable, Identifiable, Equatable {
    public let id: String
    public let nickname: String
    /// 서버가 준 원문("apple" / "google"). 과거 데이터에 다른 값이 남아 있을 수 있어
    /// SocialType으로 강제 변환하지 않는다 — 필요하면 `SocialType(rawValue:)`로 해석한다.
    public let socialType: String
    public let totalStamps: Int

    public init(id: String, nickname: String, socialType: String, totalStamps: Int) {
        self.id = id
        self.nickname = nickname
        self.socialType = socialType
        self.totalStamps = totalStamps
    }
}

/// GET /api/users/me, PATCH /api/users/me, PATCH /api/users/me/settings 응답.
/// level/levelLabel은 서버가 누적 도장 수로 계산해 내려준다 — 클라이언트가 다시 계산하지 않는다.
public struct UserProfile: Sendable, Equatable {
    public let user: User
    public let profileImageURL: URL?
    public let pushEnabled: Bool
    public let level: Int
    public let levelLabel: String

    public init(user: User, profileImageURL: URL?, pushEnabled: Bool, level: Int, levelLabel: String) {
        self.user = user
        self.profileImageURL = profileImageURL
        self.pushEnabled = pushEnabled
        self.level = level
        self.levelLabel = levelLabel
    }
}

/// GET /api/users/me/stats — 프로필 화면(수집 도시 / 소멸지역 기여도 / 누적 이동 / 기록).
public struct ProfileStats: Sendable {
    public let joinedAt: Date
    public let collectedRegions: Int
    public let totalRegions: Int
    public let depopulatedVisitedRegions: Int
    public let depopulatedVisitedPercent: Double
    public let totalDistanceKm: Double
    public let recentStamp: RecentStamp?
    public let badgeCount: Int
    public let reviewCount: Int
    public let nationalRank: Int
    public let totalUsers: Int

    public init(
        joinedAt: Date,
        collectedRegions: Int,
        totalRegions: Int,
        depopulatedVisitedRegions: Int,
        depopulatedVisitedPercent: Double,
        totalDistanceKm: Double,
        recentStamp: RecentStamp?,
        badgeCount: Int,
        reviewCount: Int,
        nationalRank: Int,
        totalUsers: Int
    ) {
        self.joinedAt = joinedAt
        self.collectedRegions = collectedRegions
        self.totalRegions = totalRegions
        self.depopulatedVisitedRegions = depopulatedVisitedRegions
        self.depopulatedVisitedPercent = depopulatedVisitedPercent
        self.totalDistanceKm = totalDistanceKm
        self.recentStamp = recentStamp
        self.badgeCount = badgeCount
        self.reviewCount = reviewCount
        self.nationalRank = nationalRank
        self.totalUsers = totalUsers
    }
}

public struct RecentStamp: Sendable, Equatable {
    public let placeName: String
    public let regionName: String
    public let checkedInAt: Date

    public init(placeName: String, regionName: String, checkedInAt: Date) {
        self.placeName = placeName
        self.regionName = regionName
        self.checkedInAt = checkedInAt
    }
}

/// GET /api/users/{userId}/detail — 랭킹 유저 상세(여권형 대시보드).
public struct RankerDetail: Sendable {
    public let userId: String
    public let nickname: String
    public let profileImageURL: URL?
    public let level: Int
    public let levelLabel: String
    public let totalStamps: Int
    /// 서버가 라벨까지 만들어 주는 요약 지표. 표시 순서도 서버가 정한다.
    public let dash: [LabeledValue]
    public let weeks: [WeekActivity]
    public let stamps: [RepresentativeStamp]

    public init(
        userId: String,
        nickname: String,
        profileImageURL: URL?,
        level: Int,
        levelLabel: String,
        totalStamps: Int,
        dash: [LabeledValue],
        weeks: [WeekActivity],
        stamps: [RepresentativeStamp]
    ) {
        self.userId = userId
        self.nickname = nickname
        self.profileImageURL = profileImageURL
        self.level = level
        self.levelLabel = levelLabel
        self.totalStamps = totalStamps
        self.dash = dash
        self.weeks = weeks
        self.stamps = stamps
    }
}

public struct WeekActivity: Sendable, Identifiable, Equatable {
    public var id: String { label }
    /// "7/1" 형태의 주 시작일 라벨.
    public let label: String
    public let count: Int

    public init(label: String, count: Int) {
        self.label = label
        self.count = count
    }
}

public struct RepresentativeStamp: Sendable, Identifiable, Equatable {
    public var id: String { regionId }
    public let regionId: String
    public let sidoName: String
    public let sigunguName: String
    public let visitCount: Int

    public init(regionId: String, sidoName: String, sigunguName: String, visitCount: Int) {
        self.regionId = regionId
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.visitCount = visitCount
    }

    /// 화면 표시용 이름. "중구"처럼 겹치는 이름을 시·도로 구분한다. (예: "인천 중구")
    public var displayName: String { RegionNaming.displayName(sido: sidoName, sigungu: sigunguName) }
}
