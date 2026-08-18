import Foundation

struct StampResultDTO: Decodable, Sendable {
    let id: String
    let placeName: String
    let regionName: String
    let isDepopulated: Bool
    let bonusMultiplier: Int
    let stampsEarned: Int
    let checkedInAt: Date
    let totalStamps: Int
    let visitorNumber: Int
    let regionLevel: Int
    let regionLeveledUp: Bool
}

struct EarnedBadgeDTO: Decodable, Sendable {
    let id: String
    let key: String
    let name: String
    let icon: String
}
