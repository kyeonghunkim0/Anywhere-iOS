import Foundation

public struct BlockedUser: Identifiable, Sendable, Equatable {
    public let id: String
    public let nickname: String
    public let profileImageURL: URL?
    public let blockedAt: Date

    public init(id: String, nickname: String, profileImageURL: URL?, blockedAt: Date) {
        self.id = id
        self.nickname = nickname
        self.profileImageURL = profileImageURL
        self.blockedAt = blockedAt
    }
}
