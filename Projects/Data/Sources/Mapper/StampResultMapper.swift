import Domain

extension StampResultDTO {
    func toEntity() -> StampResult {
        StampResult(
            id: id,
            placeName: placeName,
            regionName: regionName,
            isDepopulated: isDepopulated,
            bonusMultiplier: bonusMultiplier,
            stampsEarned: stampsEarned,
            checkedInAt: checkedInAt,
            totalStamps: totalStamps,
            visitorNumber: visitorNumber,
            regionLevel: regionLevel,
            regionLeveledUp: regionLeveledUp
        )
    }
}

extension EarnedBadgeDTO {
    func toEntity() -> EarnedBadge {
        EarnedBadge(id: id, key: key, name: name, icon: icon)
    }
}
