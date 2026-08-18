import Domain

extension UserRankItemDTO {
    func toEntity() -> UserRankItem {
        UserRankItem(rank: rank, userId: userId, nickname: nickname, totalStamps: totalStamps)
    }
}

extension PlaceRankItemDTO {
    func toEntity() -> PlaceRankItem {
        PlaceRankItem(
            rank: rank,
            regionId: regionId,
            sidoName: sidoName,
            sigunguName: sigunguName,
            isDepopulated: isDepopulated,
            visitCount: visitCount
        )
    }
}

extension MyRankDTO {
    func toEntity() -> MyRank {
        MyRank(
            rank: rank,
            totalUsers: totalUsers,
            userId: userId,
            nickname: nickname,
            totalStamps: totalStamps,
            topPercentage: topPercentage
        )
    }
}
