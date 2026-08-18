import Foundation

public struct StampResult: Sendable, Identifiable {
    public let id: String
    public let placeName: String
    public let regionName: String
    public let isDepopulated: Bool
    /// 1 = 일반, 2 = 인구감소지역 보상 2배.
    public let bonusMultiplier: Int
    public let stampsEarned: Int
    public let checkedInAt: Date
    public let totalStamps: Int
    /// 해당 지역의 N번째 방문자 각인.
    public let visitorNumber: Int
    /// 이번 체크인이 반영된 뒤의 지역 레벨.
    public let regionLevel: Int
    public let regionLeveledUp: Bool

    public init(
        id: String,
        placeName: String,
        regionName: String,
        isDepopulated: Bool,
        bonusMultiplier: Int,
        stampsEarned: Int,
        checkedInAt: Date,
        totalStamps: Int,
        visitorNumber: Int,
        regionLevel: Int,
        regionLeveledUp: Bool
    ) {
        self.id = id
        self.placeName = placeName
        self.regionName = regionName
        self.isDepopulated = isDepopulated
        self.bonusMultiplier = bonusMultiplier
        self.stampsEarned = stampsEarned
        self.checkedInAt = checkedInAt
        self.totalStamps = totalStamps
        self.visitorNumber = visitorNumber
        self.regionLevel = regionLevel
        self.regionLeveledUp = regionLeveledUp
    }
}
