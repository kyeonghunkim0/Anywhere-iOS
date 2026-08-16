import Domain
extension StampResultDTO {
    func toEntity() -> StampResult {
        StampResult(
            id: id,
            placeName: placeName,
            regionName: regionName,
            isDepopulated: isDepopulated,
            visitorOrder: visitorOrder,
            visitorOrderMessage: visitorOrderMessage,
            bonusMultiplier: bonusMultiplier,
            stampsEarned: stampsEarned,
            checkedInAt: checkedInAt,
            totalStamps: totalStamps,
            regionLevelInfo: regionLevelInfo.map {
                RegionLevelInfo(
                    regionName: $0.regionName,
                    level: $0.level,
                    isLevelUp: $0.isLevelUp,
                    visitorCount: $0.visitorCount,
                    exp: $0.exp,
                    targetVisitorCount: $0.targetVisitorCount
                )
            }
        )
    }
}
