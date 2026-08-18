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
            coordinate: Coordinate(latitude: mapY, longitude: mapX)
        )
    }
}

extension MatchedPlaceDTO {
    func toEntity() -> Place {
        Place(
            id: id,
            name: name,
            address: address,
            thumbnailURL: thumbnail.flatMap(URL.init(string:)),
            coordinate: Coordinate(latitude: mapY, longitude: mapX)
        )
    }
}

extension TaggedPlaceDTO {
    func toEntity() -> TaggedPlace {
        TaggedPlace(
            id: id,
            name: name,
            address: address,
            thumbnailURL: thumbnail.flatMap(URL.init(string:)),
            sidoName: sidoName,
            sigunguName: sigunguName,
            isDepopulated: isDepopulated
        )
    }
}
