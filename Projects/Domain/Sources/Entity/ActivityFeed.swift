import Foundation

/// GET /api/feed/recent — 홈 상단 실시간 방문 티커.
public struct FeedItem: Sendable, Identifiable, Equatable {
    public let id: String
    public let nickname: String
    public let sidoName: String
    public let sigunguName: String
    public let placeName: String
    public let isDepopulated: Bool
    public let checkedInAt: Date
    /// 서버가 만들어 주는 표시용 문장 ("OOO님이 부천시 도장을 획득했습니다!").
    public let message: String

    public init(
        id: String,
        nickname: String,
        sidoName: String,
        sigunguName: String,
        placeName: String,
        isDepopulated: Bool,
        checkedInAt: Date,
        message: String
    ) {
        self.id = id
        self.nickname = nickname
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.placeName = placeName
        self.isDepopulated = isDepopulated
        self.checkedInAt = checkedInAt
        self.message = message
    }
}

public struct ActivityFeed: Sendable {
    public let items: [FeedItem]
    public let totalCount: Int

    public init(items: [FeedItem], totalCount: Int) {
        self.items = items
        self.totalCount = totalCount
    }
}
