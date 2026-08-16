import Foundation

public struct PassportRegion: Sendable, Identifiable {
    public var id: String { regionId }
    public let regionId: String
    public let sidoName: String
    public let sigunguName: String
    public let isDepopulated: Bool
    public let isVisited: Bool
    public let visitCount: Int
    public let lastVisitedAt: Date?
    public let visitorOrder: Int?

    public init(
        regionId: String,
        sidoName: String,
        sigunguName: String,
        isDepopulated: Bool,
        isVisited: Bool,
        visitCount: Int,
        lastVisitedAt: Date?,
        visitorOrder: Int?
    ) {
        self.regionId = regionId
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.isDepopulated = isDepopulated
        self.isVisited = isVisited
        self.visitCount = visitCount
        self.lastVisitedAt = lastVisitedAt
        self.visitorOrder = visitorOrder
    }
}

public struct BadgeCollectionItem: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let type: QuestType
    /// 미수집 뱃지는 서버가 null로 내려준다 (실루엣 처리 의도).
    public let imageURL: URL?
    public let isAcquired: Bool
    public let acquiredAt: Date?
    public let visitorOrder: Int?
    public let visitorOrderMessage: String

    public init(
        id: String,
        title: String,
        description: String,
        type: QuestType,
        imageURL: URL?,
        isAcquired: Bool,
        acquiredAt: Date?,
        visitorOrder: Int?,
        visitorOrderMessage: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.imageURL = imageURL
        self.isAcquired = isAcquired
        self.acquiredAt = acquiredAt
        self.visitorOrder = visitorOrder
        self.visitorOrderMessage = visitorOrderMessage
    }
}

public struct StampEngraving: Sendable, Identifiable {
    public let id: String
    public let placeName: String
    public let regionName: String
    public let isDepopulated: Bool
    public let visitorOrder: Int
    public let engravingText: String
    public let checkedInAt: Date

    public init(
        id: String,
        placeName: String,
        regionName: String,
        isDepopulated: Bool,
        visitorOrder: Int,
        engravingText: String,
        checkedInAt: Date
    ) {
        self.id = id
        self.placeName = placeName
        self.regionName = regionName
        self.isDepopulated = isDepopulated
        self.visitorOrder = visitorOrder
        self.engravingText = engravingText
        self.checkedInAt = checkedInAt
    }
}

public struct PassportUser: Sendable {
    public let id: String
    public let nickname: String
    public let profileImageURL: URL?
    public let level: Int
    public let exp: Int
    public let totalStamps: Int
    public let totalDistanceKm: Double

    public init(
        id: String,
        nickname: String,
        profileImageURL: URL?,
        level: Int,
        exp: Int,
        totalStamps: Int,
        totalDistanceKm: Double
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageURL = profileImageURL
        self.level = level
        self.exp = exp
        self.totalStamps = totalStamps
        self.totalDistanceKm = totalDistanceKm
    }
}

public struct PassportContribution: Sendable, Equatable {
    public let totalVisitedRegions: Int
    public let depopulatedVisitedCount: Int
    public let depopulatedRatioPercent: Int
    public let topPercentileText: String

    public init(
        totalVisitedRegions: Int,
        depopulatedVisitedCount: Int,
        depopulatedRatioPercent: Int,
        topPercentileText: String
    ) {
        self.totalVisitedRegions = totalVisitedRegions
        self.depopulatedVisitedCount = depopulatedVisitedCount
        self.depopulatedRatioPercent = depopulatedRatioPercent
        self.topPercentileText = topPercentileText
    }
}

public struct Passport: Sendable {
    public let user: PassportUser
    public let contribution: PassportContribution
    public let completionRate: Double
    public let badgeCollection: [BadgeCollectionItem]
    public let stampEngravings: [StampEngraving]
    public let regions: [PassportRegion]

    public init(
        user: PassportUser,
        contribution: PassportContribution,
        completionRate: Double,
        badgeCollection: [BadgeCollectionItem],
        stampEngravings: [StampEngraving],
        regions: [PassportRegion]
    ) {
        self.user = user
        self.contribution = contribution
        self.completionRate = completionRate
        self.badgeCollection = badgeCollection
        self.stampEngravings = stampEngravings
        self.regions = regions
    }
}
