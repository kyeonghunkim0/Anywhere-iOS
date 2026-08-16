import Foundation
import Domain

extension UserDTO {
    func toEntity() -> User {
        User(
            id: id,
            nickname: nickname,
            socialType: SocialType(rawValue: socialType) ?? .kakao,
            profileImageURL: profileImage.flatMap(URL.init(string:)),
            level: level,
            exp: exp,
            totalDistanceKm: totalDistance,
            totalStamps: totalStamps,
            depopulatedVisitCount: depopulatedVisitCount
        )
    }
}

extension UserProfileDTO {
    func toEntity() -> UserProfile {
        UserProfile(
            user: User(
                id: id,
                nickname: nickname,
                socialType: SocialType(rawValue: socialType) ?? .kakao,
                profileImageURL: profileImage.flatMap(URL.init(string:)),
                level: level,
                exp: exp,
                totalDistanceKm: totalDistance,
                totalStamps: totalStamps,
                depopulatedVisitCount: depopulatedVisitCount
            ),
            badgeCount: badgeCount,
            topPercentile: topPercentile
        )
    }
}
