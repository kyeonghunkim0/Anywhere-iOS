import Foundation

public struct PassportRegion: Sendable, Identifiable, Equatable {
    public var id: String { regionId }
    public let regionId: String
    public let sidoName: String
    public let sigunguName: String
    public let isDepopulated: Bool
    public let isVisited: Bool
    public let visitCount: Int
    public let lastVisitedAt: Date?
    /// 지역의 로컬 성장 레벨.
    public let level: Int
    /// 내가 그 지역의 몇 번째 방문자였는지 (최초 방문 기준). 미방문이면 nil.
    public let visitorNumber: Int?
    /// 이 칸에 들어갈 기초자치단체 뱃지. 방문 여부와 무관하게 채워지며,
    /// 아직 뱃지가 없는 지역은 nil이다.
    public let badge: RegionBadge?

    public init(
        regionId: String,
        sidoName: String,
        sigunguName: String,
        isDepopulated: Bool,
        isVisited: Bool,
        visitCount: Int,
        lastVisitedAt: Date?,
        level: Int,
        visitorNumber: Int?,
        badge: RegionBadge? = nil
    ) {
        self.regionId = regionId
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.isDepopulated = isDepopulated
        self.isVisited = isVisited
        self.visitCount = visitCount
        self.lastVisitedAt = lastVisitedAt
        self.level = level
        self.visitorNumber = visitorNumber
        self.badge = badge
    }

    public var fullName: String { "\(sidoName) \(sigunguName)" }

    /// 화면 표시용 이름. "중구"처럼 겹치는 이름을 시·도로 구분한다. (예: "인천 중구")
    public var displayName: String { RegionNaming.displayName(sido: sidoName, sigungu: sigunguName) }
}

/// GET /api/passport/{userId} — 전국 기초자치단체 도장 수집 현황.
public struct Passport: Sendable {
    public let userId: String
    public let nickname: String
    public let totalStamps: Int
    public let totalRegions: Int
    public let visitedRegions: Int
    /// 0~100 퍼센트.
    public let completionRate: Double
    public let regions: [PassportRegion]

    public init(
        userId: String,
        nickname: String,
        totalStamps: Int,
        totalRegions: Int,
        visitedRegions: Int,
        completionRate: Double,
        regions: [PassportRegion]
    ) {
        self.userId = userId
        self.nickname = nickname
        self.totalStamps = totalStamps
        self.totalRegions = totalRegions
        self.visitedRegions = visitedRegions
        self.completionRate = completionRate
        self.regions = regions
    }
}
