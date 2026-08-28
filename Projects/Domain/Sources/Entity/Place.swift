import Foundation

public struct Place: Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let address: String
    public let thumbnailURL: URL?
    public let coordinate: Coordinate

    public init(id: String, name: String, address: String, thumbnailURL: URL?, coordinate: Coordinate) {
        self.id = id
        self.name = name
        self.address = address
        self.thumbnailURL = thumbnailURL
        self.coordinate = coordinate
    }
}

/// GET /api/tags/{tagId}/places — 좌표 없이 지역 라벨만 함께 오는 목록용 표현.
public struct TaggedPlace: Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let address: String
    public let thumbnailURL: URL?
    public let sidoName: String
    public let sigunguName: String
    public let isDepopulated: Bool

    public init(
        id: String,
        name: String,
        address: String,
        thumbnailURL: URL?,
        sidoName: String,
        sigunguName: String,
        isDepopulated: Bool
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.thumbnailURL = thumbnailURL
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.isDepopulated = isDepopulated
    }
}

/// 체크인·후기가 실제로 쓰는 최소 정보. 좌표 없는 목록형 장소(`TaggedPlace`)도
/// 같은 화면으로 보낼 수 있게, 두 표현이 공통으로 가진 id와 이름만 들고 다닌다.
public struct PlaceRef: Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    public init(_ place: Place) {
        self.init(id: place.id, name: place.name)
    }

    public init(_ place: TaggedPlace) {
        self.init(id: place.id, name: place.name)
    }
}
