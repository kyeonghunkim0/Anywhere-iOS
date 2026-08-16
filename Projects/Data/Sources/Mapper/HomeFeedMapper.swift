import Domain
extension HomeFeedDTO {
    func toEntity() -> HomeFeed {
        HomeFeed(
            tags: tags.map { CurationTag(id: $0.id, name: $0.name, icon: $0.icon) },
            specialQuests: specialQuests.map { $0.toEntity() },
            growingRegions: growingRegions.map { dto in
                GrowingRegion(
                    id: dto.id,
                    sidoName: dto.sidoName,
                    sigunguName: dto.sigunguName,
                    level: dto.level,
                    exp: dto.exp,
                    targetVisitorCount: dto.targetVisitorCount,
                    remainingVisitors: dto.remainingVisitors,
                    progressPercent: dto.progressPercent,
                    isDepopulated: dto.isDepopulated,
                    visitorCount: dto.visitorCount,
                    message: dto.message
                )
            },
            ticker: ticker.map { FeedTickerItem(id: $0.id, message: $0.message, checkedInAt: $0.checkedInAt) }
        )
    }
}
