import Domain

extension ActivityFeedDTO {
    func toEntity() -> ActivityFeed {
        ActivityFeed(
            items: items.map { dto in
                FeedItem(
                    id: dto.id,
                    nickname: dto.nickname,
                    sidoName: dto.sidoName,
                    sigunguName: dto.sigunguName,
                    placeName: dto.placeName,
                    isDepopulated: dto.isDepopulated,
                    checkedInAt: dto.checkedInAt,
                    message: dto.message
                )
            },
            totalCount: totalCount
        )
    }
}
