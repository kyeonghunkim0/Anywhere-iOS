import Foundation

struct UserDTO: Decodable, Sendable {
    let id: String
    let nickname: String
    let socialType: String
    let profileImage: String?
    let level: Int
    let exp: Int
    let totalDistance: Double
    let totalStamps: Int
    let depopulatedVisitCount: Int
}

struct UserProfileDTO: Decodable, Sendable {
    let id: String
    let nickname: String
    let socialType: String
    let profileImage: String?
    let level: Int
    let exp: Int
    let totalDistance: Double
    let totalStamps: Int
    let depopulatedVisitCount: Int
    let badgeCount: Int
    let topPercentile: Int
}
