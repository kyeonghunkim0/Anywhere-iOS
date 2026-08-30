/// 매칭/여정 응답에 실려 오는 장소. mapX가 경도, mapY가 위도다 — 이름 순서가 관례와 반대다.
struct PlaceDTO: Decodable, Sendable {
    let id: String
    let name: String
    let address: String
    let thumbnail: String?
    /// 경도.
    let mapX: Double
    /// 위도.
    let mapY: Double
}

/// GET /api/match/random의 place는 거리(distanceKm)를 함께 담고 온다.
struct MatchedPlaceDTO: Decodable, Sendable {
    let id: String
    let name: String
    let address: String
    let thumbnail: String?
    let mapX: Double
    let mapY: Double
    let distanceKm: Double
}

/// GET /api/tags/{tagId}/places — 좌표 없이 지역 라벨만 온다.
struct TaggedPlaceDTO: Decodable, Sendable {
    let id: String
    let name: String
    let address: String
    let thumbnail: String?
    let sidoName: String
    let sigunguName: String
    let isDepopulated: Bool
}

struct PlaceTagDTO: Decodable, Sendable {
    let id: String
    let label: String
    let emoji: String?
}

/// GET /api/places/{placeId}.
struct PlaceDetailDTO: Decodable, Sendable {
    let id: String
    let name: String
    let address: String
    let thumbnail: String?
    let mapX: Double
    let mapY: Double
    let region: RegionDTO
    let tags: [PlaceTagDTO]
    let stampCount: Int
    let reviewCount: Int
    let reviews: [PlaceReviewDTO]
}
