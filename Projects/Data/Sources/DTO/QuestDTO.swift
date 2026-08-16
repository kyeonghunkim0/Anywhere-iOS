import Foundation

struct QuestDTO: Decodable, Sendable {
    let id: String
    let title: String
    let description: String
    let type: String
    let imageUrl: String?
    let startDate: Date?
    let endDate: Date?
    let dDay: String?
    let radius: Double
    let mapX: Double?
    let mapY: Double?
    let regionName: String?
    let isDepopulated: Bool
    let isAcquired: Bool
}

struct ClaimedBadgeDTO: Decodable, Sendable {
    let id: String
    let title: String
    let description: String
    let type: String
    let imageUrl: String?
    let acquiredAt: Date
    let visitorOrder: Int
    let visitorOrderMessage: String
}
