struct UserRankItemDTO: Decodable, Sendable {
    let rank: Int
    let userId: String
    let nickname: String
    let profileImage: String?
    let score: Int
    let totalStamps: Int
    let depopulatedVisits: Int
    let level: Int
}

struct MyRankDTO: Decodable, Sendable {
    let rank: Int
    let userId: String
    let nickname: String
    let profileImage: String?
    let score: Int
    let totalStamps: Int
    let depopulatedVisits: Int
    let level: Int
    let totalUsers: Int
    let topPercentage: Double
}
