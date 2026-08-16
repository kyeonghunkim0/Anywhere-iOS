import Foundation

public enum RankingPeriod: String, Sendable {
    case month
    case total
}

public struct UserRankItem: Sendable, Identifiable {
    public var id: String { userId }
    public let rank: Int
    public let userId: String
    public let nickname: String
    public let profileImageURL: URL?
    public let score: Int
    public let totalStamps: Int
    public let depopulatedVisits: Int
    public let level: Int

    public init(
        rank: Int,
        userId: String,
        nickname: String,
        profileImageURL: URL?,
        score: Int,
        totalStamps: Int,
        depopulatedVisits: Int,
        level: Int
    ) {
        self.rank = rank
        self.userId = userId
        self.nickname = nickname
        self.profileImageURL = profileImageURL
        self.score = score
        self.totalStamps = totalStamps
        self.depopulatedVisits = depopulatedVisits
        self.level = level
    }
}

public struct MyRank: Sendable {
    public let item: UserRankItem
    public let totalUsers: Int
    public let topPercentage: Double

    public init(item: UserRankItem, totalUsers: Int, topPercentage: Double) {
        self.item = item
        self.totalUsers = totalUsers
        self.topPercentage = topPercentage
    }
}
