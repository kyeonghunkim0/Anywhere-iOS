import Foundation
import Domain

/// 서버가 게스트 계정에 원문으로 내려주는 socialType. 이 값으로 `isGuest`를 판별한다 —
/// 별도 isGuest 필드는 POST /api/auth/guest 응답에만 있고 다른 유저 조회 엔드포인트엔 없다.
private let guestSocialType = "guest"

extension UserDTO {
    func toEntity() -> User {
        User(
            id: id,
            nickname: nickname,
            socialType: socialType,
            totalStamps: totalStamps,
            isGuest: socialType == guestSocialType
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
                totalStamps: totalStamps,
                isGuest: socialType == guestSocialType
            ),
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

extension BlockedUserDTO {
    func toEntity() -> BlockedUser {
        BlockedUser(
            id: id,
            nickname: nickname,
            profileImageURL: profileImage.flatMap(URL.init(string:)),
            blockedAt: blockedAt
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
                    visitCount: $0.visitCount,
                    badge: $0.badge?.toEntity()
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
