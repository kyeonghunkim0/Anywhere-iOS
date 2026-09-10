import Foundation
import Domain

extension SearchResultDTO {
    func toEntity() -> SearchResult {
        SearchResult(
            query: query,
            regions: regions.items.map { $0.toEntity() },
            places: places.toEntity()
        )
    }
}

extension SearchedRegionDTO {
    func toEntity() -> SearchedRegion {
        SearchedRegion(
            regionId: regionId,
            sidoName: sidoName,
            sigunguName: sigunguName,
            isDepopulated: isDepopulated,
            imageURL: imageUrl.flatMap(URL.init(string:))
        )
    }
}

extension SearchedPlacePageDTO {
    func toEntity() -> SearchedPlacePage {
        SearchedPlacePage(
            total: total,
            limit: limit,
            offset: offset,
            items: items.map { $0.toEntity() }
        )
    }
}

extension SearchedPlaceDTO {
    /// 목록 행과 TripPlanModel이 이미 TaggedPlace로 돌아가므로 같은 타입으로 맞춘다.
    /// 검색 응답만 지역을 중첩해 주기 때문에 여기서 평평하게 편다.
    func toEntity() -> TaggedPlace {
        TaggedPlace(
            id: id,
            name: name,
            address: address,
            thumbnailURL: thumbnail.flatMap(URL.init(string:)),
            sidoName: region.sidoName,
            sigunguName: region.sigunguName,
            isDepopulated: region.isDepopulated,
            // mapX는 경도, mapY는 위도다 — 이름 순서가 관례와 반대다.
            coordinate: Coordinate(latitude: mapY, longitude: mapX)
        )
    }
}
