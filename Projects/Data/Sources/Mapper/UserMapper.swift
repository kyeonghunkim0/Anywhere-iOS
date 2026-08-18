import Foundation
import Domain

extension UserDTO {
    func toEntity() -> User {
        User(
            id: id,
            nickname: nickname,
            socialType: socialType,
            totalStamps: totalStamps
        )
    }
}

extension UserProfileDTO {
    func toEntity() -> UserProfile {
        UserProfile(
            user: User(
                id: id,
                nickname: nickname,
                socialType: socialType,
                totalStamps: totalStamps
            ),
            profileImageURL: profileImage.flatMap(URL.init(string:)),
            pushEnabled: pushEnabled,
            level: level,
            levelLabel: levelLabel
        )
    }
}

extension ProfileStatsDTO {
    func toEntity() -> ProfileStats {
        ProfileStats(
            joinedAt: joinedAt,
            collectedRegions: collectedRegions,
            totalRegions: totalRegions,
            depopulatedVisitedRegions: depopulatedVisitedRegions,
            depopulatedVisitedPercent: depopulatedVisitedPercent,
            totalDistanceKm: totalDistanceKm,
            recentStamp: recentStamp.map {
                RecentStamp(placeName: $0.placeName, regionName: $0.regionName, checkedInAt: $0.checkedInAt)
            },
            badgeCount: badgeCount,
            reviewCount: reviewCount,
            nationalRank: nationalRank,
            totalUsers: totalUsers
        )
    }
}

extension RankerDetailDTO {
    func toEntity() -> RankerDetail {
        RankerDetail(
            userId: userId,
            nickname: nickname,
            profileImageURL: profileImage.flatMap(URL.init(string:)),
            level: level,
            levelLabel: levelLabel,
            totalStamps: totalStamps,
            dash: dash.map { $0.toEntity() },
            weeks: weeks.map { WeekActivity(label: $0.label, count: $0.count) },
            stamps: stamps.map {
                RepresentativeStamp(
                    regionId: $0.regionId,
                    sidoName: $0.sidoName,
                    sigunguName: $0.sigunguName,
                    visitCount: $0.visitCount
                )
            }
        )
    }
}

extension LabeledValueDTO {
    func toEntity() -> LabeledValue {
        LabeledValue(label: label, value: value)
    }
}
