struct RegionDTO: Decodable, Sendable {
    let id: String
    let sidoName: String
    let sigunguName: String
    let isDepopulated: Bool
    let level: Int
    let visitorCount: Int
}
