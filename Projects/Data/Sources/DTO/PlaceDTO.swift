struct PlaceDTO: Decodable, Sendable {
    let id: String
    let name: String
    let address: String
    let thumbnail: String?
    /// 경도. 이름과 달리 위도가 아니다 — Mapper에서 반드시 뒤집는다.
    let mapX: Double
    /// 위도.
    let mapY: Double
    let distanceKm: Double
    let localRecommendation: String
    let tags: [String]
}
