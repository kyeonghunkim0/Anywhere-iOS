import Foundation

/// GET /api/search.
struct SearchResultDTO: Decodable, Sendable {
    let query: String
    /// 서버가 지역도 관광지와 같은 { total, limit, offset, items } 페이지로 내려준다.
    let regions: SearchedRegionPageDTO
    let places: SearchedPlacePageDTO
    /// 최대 20건, 페이징 없이 통째로 내려온다.
    let festivals: [FestivalDTO]
}

struct SearchedRegionPageDTO: Decodable, Sendable {
    let total: Int
    let limit: Int
    let offset: Int
    let items: [SearchedRegionDTO]
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

struct FestivalDTO: Decodable, Sendable {
    let id: String
    let key: String
    let name: String
    let description: String
    /// 완전한 이미지 URL로 온다.
    let icon: String?
    let status: String
    let startAt: Date
    let endAt: Date
    /// 종료까지 남은 일수. 이미 끝났으면 음수일 수 있다.
    let daysRemaining: Int
    let region: RegionDTO
}
