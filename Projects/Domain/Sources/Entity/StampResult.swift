import Foundation

public struct RegionLevelInfo: Sendable, Equatable {
    public let regionName: String
    public let level: Int
    public let isLevelUp: Bool
    public let visitorCount: Int
    public let exp: Int
    public let targetVisitorCount: Int

    public init(
        regionName: String,
        level: Int,
        isLevelUp: Bool,
        visitorCount: Int,
        exp: Int,
        targetVisitorCount: Int
    ) {
        self.regionName = regionName
        self.level = level
        self.isLevelUp = isLevelUp
        self.visitorCount = visitorCount
        self.exp = exp
        self.targetVisitorCount = targetVisitorCount
    }
}

public struct StampResult: Sendable, Identifiable {
    public let id: String
    public let placeName: String
    public let regionName: String
    public let isDepopulated: Bool
    public let visitorOrder: Int
    public let visitorOrderMessage: String
    public let bonusMultiplier: Int
    public let stampsEarned: Int
    public let checkedInAt: Date
    public let totalStamps: Int
    public let regionLevelInfo: RegionLevelInfo?

    public init(
        id: String,
        placeName: String,
        regionName: String,
        isDepopulated: Bool,
        visitorOrder: Int,
        visitorOrderMessage: String,
        bonusMultiplier: Int,
        stampsEarned: Int,
        checkedInAt: Date,
        totalStamps: Int,
        regionLevelInfo: RegionLevelInfo?
    ) {
        self.id = id
        self.placeName = placeName
        self.regionName = regionName
        self.isDepopulated = isDepopulated
        self.visitorOrder = visitorOrder
        self.visitorOrderMessage = visitorOrderMessage
        self.bonusMultiplier = bonusMultiplier
        self.stampsEarned = stampsEarned
        self.checkedInAt = checkedInAt
        self.totalStamps = totalStamps
        self.regionLevelInfo = regionLevelInfo
    }
}
