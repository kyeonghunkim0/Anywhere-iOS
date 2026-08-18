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

    public init(
        regionId: String,
        sidoName: String,
        sigunguName: String,
        isDepopulated: Bool,
        isVisited: Bool,
        visitCount: Int,
        lastVisitedAt: Date?,
        level: Int,
        visitorNumber: Int?
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
    }

    public var fullName: String { "\(sidoName) \(sigunguName)" }
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
