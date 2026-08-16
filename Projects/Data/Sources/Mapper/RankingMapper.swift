import Foundation
import Domain

extension UserRankItemDTO {
    func toEntity() -> UserRankItem {
        UserRankItem(
            rank: rank,
            userId: userId,
            nickname: nickname,
            profileImageURL: profileImage.flatMap(URL.init(string:)),
            score: score,
            totalStamps: totalStamps,
            depopulatedVisits: depopulatedVisits,
            level: level
        )
    }
}

extension MyRankDTO {
    func toEntity() -> MyRank {
        MyRank(
            item: UserRankItem(
                rank: rank,
                userId: userId,
                nickname: nickname,
                profileImageURL: profileImage.flatMap(URL.init(string:)),
                score: score,
                totalStamps: totalStamps,
                depopulatedVisits: depopulatedVisits,
                level: level
            ),
            totalUsers: totalUsers,
            topPercentage: topPercentage
        )
    }
}
