import Foundation

struct RegionLevelInfoDTO: Decodable, Sendable {
    let regionName: String
    let level: Int
    let isLevelUp: Bool
    let visitorCount: Int
    let exp: Int
    let targetVisitorCount: Int
}

struct StampResultDTO: Decodable, Sendable {
    let id: String
    let placeName: String
    let regionName: String
    let isDepopulated: Bool
    let visitorOrder: Int
    let visitorOrderMessage: String
    let bonusMultiplier: Int
    let stampsEarned: Int
    let checkedInAt: Date
    let totalStamps: Int
    let regionLevelInfo: RegionLevelInfoDTO?
}
