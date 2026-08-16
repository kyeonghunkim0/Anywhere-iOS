import Foundation

public struct CurationTag: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let icon: String

    public init(id: String, name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

public struct GrowingRegion: Sendable, Identifiable {
    public let id: String
    public let sidoName: String
    public let sigunguName: String
    public let level: Int
    public let exp: Int
    public let targetVisitorCount: Int
    public let remainingVisitors: Int
    public let progressPercent: Int
    public let isDepopulated: Bool
    public let visitorCount: Int
    /// 서버가 만들어 주는 표시용 문자열 (예: "3명만 더 오면 Lv.3 레벨업!").
    public let message: String

    public init(
        id: String,
        sidoName: String,
        sigunguName: String,
        level: Int,
        exp: Int,
        targetVisitorCount: Int,
        remainingVisitors: Int,
        progressPercent: Int,
        isDepopulated: Bool,
        visitorCount: Int,
        message: String
    ) {
        self.id = id
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.level = level
        self.exp = exp
        self.targetVisitorCount = targetVisitorCount
        self.remainingVisitors = remainingVisitors
        self.progressPercent = progressPercent
        self.isDepopulated = isDepopulated
        self.visitorCount = visitorCount
        self.message = message
    }
}

public struct FeedTickerItem: Sendable, Identifiable {
    public let id: String
    public let message: String
    public let checkedInAt: Date

    public init(id: String, message: String, checkedInAt: Date) {
        self.id = id
        self.message = message
        self.checkedInAt = checkedInAt
    }
}

public struct HomeFeed: Sendable {
    public let tags: [CurationTag]
    public let specialQuests: [Quest]
    public let growingRegions: [GrowingRegion]
    public let ticker: [FeedTickerItem]

    public init(
        tags: [CurationTag],
        specialQuests: [Quest],
        growingRegions: [GrowingRegion],
        ticker: [FeedTickerItem]
    ) {
        self.tags = tags
        self.specialQuests = specialQuests
        self.growingRegions = growingRegions
        self.ticker = ticker
    }
}
