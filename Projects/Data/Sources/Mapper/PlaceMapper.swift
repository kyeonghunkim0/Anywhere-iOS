import Foundation
import Domain

extension PlaceDTO {
    func toEntity() -> Place {
        Place(
            id: id,
            name: name,
            address: address,
            thumbnailURL: thumbnail.flatMap(URL.init(string:)),
            // mapX는 경도, mapY는 위도다 — 이름 순서가 관례와 반대다.
            coordinate: Coordinate(latitude: mapY, longitude: mapX),
            distanceKm: distanceKm,
            localRecommendation: localRecommendation,
            tags: tags
        )
    }
}

extension RegionDTO {
    func toEntity() -> Region {
        Region(
            id: id,
            sidoName: sidoName,
            sigunguName: sigunguName,
            isDepopulated: isDepopulated,
            level: level,
            visitorCount: visitorCount
        )
    }
}
