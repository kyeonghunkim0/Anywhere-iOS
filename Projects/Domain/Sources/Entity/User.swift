import Foundation

public struct User: Sendable, Identifiable {
    public let id: String
    public let nickname: String
    public let socialType: SocialType
    public let profileImageURL: URL?
    public let level: Int
    public let exp: Int
    public let totalDistanceKm: Double
    public let totalStamps: Int
    public let depopulatedVisitCount: Int

    public init(
        id: String,
        nickname: String,
        socialType: SocialType,
        profileImageURL: URL?,
        level: Int,
        exp: Int,
        totalDistanceKm: Double,
        totalStamps: Int,
        depopulatedVisitCount: Int
    ) {
        self.id = id
        self.nickname = nickname
        self.socialType = socialType
        self.profileImageURL = profileImageURL
        self.level = level
        self.exp = exp
        self.totalDistanceKm = totalDistanceKm
        self.totalStamps = totalStamps
        self.depopulatedVisitCount = depopulatedVisitCount
    }
}

extension User: Equatable {}

/// GET /api/auth/me 전용. User + 기여도 통계.
public struct UserProfile: Sendable {
    public let user: User
    public let badgeCount: Int
    public let topPercentile: Int

    public init(user: User, badgeCount: Int, topPercentile: Int) {
        self.user = user
        self.badgeCount = badgeCount
        self.topPercentile = topPercentile
    }
}
