import Foundation

public struct Place: Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let address: String
    public let thumbnailURL: URL?
    public let coordinate: Coordinate
    /// 가장 최근 방문 후기. 후기가 하나도 없으면 nil.
    public let latestReview: PlaceLatestReview?

    public init(
        id: String,
        name: String,
        address: String,
        thumbnailURL: URL?,
        coordinate: Coordinate,
        latestReview: PlaceLatestReview? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.thumbnailURL = thumbnailURL
        self.coordinate = coordinate
        self.latestReview = latestReview
    }
}

/// 매칭 응답에 실려 오는 장소의 최근 방문 후기.
public struct PlaceLatestReview: Sendable, Hashable, Identifiable {
    public let id: String
    public let content: String
    public let nickname: String
    public let createdAt: Date

    public init(id: String, content: String, nickname: String, createdAt: Date) {
        self.id = id
        self.content = content
        self.nickname = nickname
        self.createdAt = createdAt
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
    /// 검색 API만 좌표를 함께 준다. 태그 목록에서 온 장소는 nil이라 거리를 낼 수 없다.
    public let coordinate: Coordinate?

    public init(
        id: String,
        name: String,
        address: String,
        thumbnailURL: URL?,
        sidoName: String,
        sigunguName: String,
        isDepopulated: Bool,
        coordinate: Coordinate? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.thumbnailURL = thumbnailURL
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.isDepopulated = isDepopulated
        self.coordinate = coordinate
    }

    /// 화면 표시용 이름. "중구"처럼 겹치는 이름을 시·도로 구분한다. (예: "인천 중구")
    public var displayName: String { RegionNaming.displayName(sido: sidoName, sigungu: sigunguName) }
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

/// 장소에 붙은 큐레이션 태그. 목록 API의 CurationTag와 달리 placeCount가 없다.
public struct PlaceTag: Sendable, Identifiable, Hashable {
    public let id: String
    public let label: String
    public let emoji: String?

    public init(id: String, label: String, emoji: String?) {
        self.id = id
        self.label = label
        self.emoji = emoji
    }
}

/// GET /api/places/{placeId} — 좌표·지역·태그·도장수·후기를 한 번에 준다.
public struct PlaceDetail: Sendable, Identifiable {
    public let id: String
    public let name: String
    public let address: String
    public let thumbnailURL: URL?
    public let coordinate: Coordinate
    public let region: Region
    public let tags: [PlaceTag]
    /// 이 장소에서 발급된 도장 수.
    public let stampCount: Int
    public let reviewCount: Int
    /// 서버가 함께 실어 보내는 최근 후기 — 따로 후기 API를 부르지 않아도 된다.
    public let reviews: [PlaceReview]

    public init(
        id: String,
        name: String,
        address: String,
        thumbnailURL: URL?,
        coordinate: Coordinate,
        region: Region,
        tags: [PlaceTag],
        stampCount: Int,
        reviewCount: Int,
        reviews: [PlaceReview]
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.thumbnailURL = thumbnailURL
        self.coordinate = coordinate
        self.region = region
        self.tags = tags
        self.stampCount = stampCount
        self.reviewCount = reviewCount
        self.reviews = reviews
    }
}
