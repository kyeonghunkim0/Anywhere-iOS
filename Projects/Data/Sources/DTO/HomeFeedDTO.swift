import Foundation

struct CurationTagDTO: Decodable, Sendable {
    let id: String
    let name: String
    let icon: String
}

struct GrowingRegionDTO: Decodable, Sendable {
    let id: String
    let sidoName: String
    let sigunguName: String
    let level: Int
    let exp: Int
    let targetVisitorCount: Int
    let remainingVisitors: Int
    let progressPercent: Int
    let isDepopulated: Bool
    let visitorCount: Int
    let message: String
}

struct FeedTickerItemDTO: Decodable, Sendable {
    let id: String
    let message: String
    let checkedInAt: Date
}

struct HomeFeedDTO: Decodable, Sendable {
    let tags: [CurationTagDTO]
    let specialQuests: [QuestDTO]
    let growingRegions: [GrowingRegionDTO]
    let ticker: [FeedTickerItemDTO]
}
