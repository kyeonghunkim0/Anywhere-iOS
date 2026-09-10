/// GET /api/search.
struct SearchResultDTO: Decodable, Sendable {
    let query: String
    let regions: [SearchedRegionDTO]
    let places: SearchedPlacePageDTO
}

struct SearchedRegionDTO: Decodable, Sendable {
    let regionId: String
    let sidoName: String
    let sigunguName: String
    let isDepopulated: Bool
    let imageUrl: String?
}

struct SearchedPlacePageDTO: Decodable, Sendable {
    /// 검색어에 걸린 전체 개수. items.count와 다르다.
    let total: Int
    let limit: Int
    let offset: Int
    let items: [SearchedPlaceDTO]
}

/// stampCount도 함께 오지만 목록 행이 안 쓴다 — 안 쓰는 필드를 받아 두면
/// 서버가 모양을 바꿀 때 디코딩만 깨진다.
struct SearchedPlaceDTO: Decodable, Sendable {
    let id: String
    let name: String
    let address: String
    let thumbnail: String?
    /// 경도.
    let mapX: Double
    /// 위도.
    let mapY: Double
    let region: RegionDTO
}
