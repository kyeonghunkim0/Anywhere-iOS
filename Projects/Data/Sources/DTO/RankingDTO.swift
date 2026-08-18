struct UserRankItemDTO: Decodable, Sendable {
    let rank: Int
    let userId: String
    let nickname: String
    let totalStamps: Int
}

struct PlaceRankItemDTO: Decodable, Sendable {
    let rank: Int
    let regionId: String
    let sidoName: String
    let sigunguName: String
    let isDepopulated: Bool
    let visitCount: Int
}

struct MyRankDTO: Decodable, Sendable {
    let rank: Int
    let totalUsers: Int
    let userId: String
    let nickname: String
    let totalStamps: Int
    let topPercentage: Double
}
