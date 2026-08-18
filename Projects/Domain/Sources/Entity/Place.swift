import Foundation

public struct Place: Sendable, Identifiable, Equatable {
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
public struct TaggedPlace: Sendable, Identifiable, Equatable {
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
