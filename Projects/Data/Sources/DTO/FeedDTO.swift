import Foundation

struct FeedItemDTO: Decodable, Sendable {
    let id: String
    let nickname: String
    let sidoName: String
    let sigunguName: String
    let placeName: String
    let isDepopulated: Bool
    let checkedInAt: Date
    let message: String
}

/// GET /api/feed/recent.
struct ActivityFeedDTO: Decodable, Sendable {
    let items: [FeedItemDTO]
    let totalCount: Int
}
