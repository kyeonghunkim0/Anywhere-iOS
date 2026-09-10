import Foundation

/// GET /api/search — 지역과 관광지를 한 번에 찾는다. 인증이 필요 없다.
public struct SearchResult: Sendable {
    public let query: String
    /// 이름이 걸린 기초자치단체. "내 맘대로 고르기"는 장소만 고를 수 있어 아직
    /// 화면에 그리지 않지만, 엔드포인트가 주는 절반이라 모델에는 남겨 둔다.
    public let regions: [SearchedRegion]
    public let places: SearchedPlacePage

    public init(query: String, regions: [SearchedRegion], places: SearchedPlacePage) {
        self.query = query
        self.regions = regions
        self.places = places
    }

    /// 검색어가 비었을 때 요청 없이 돌려줄 빈 결과.
    public static func empty(query: String = "") -> SearchResult {
        SearchResult(query: query, regions: [], places: .empty)
    }
}

public struct SearchedRegion: Sendable, Identifiable, Equatable {
    public var id: String { regionId }
    public let regionId: String
    public let sidoName: String
    public let sigunguName: String
    public let isDepopulated: Bool
    public let imageURL: URL?

    public init(
        regionId: String,
        sidoName: String,
        sigunguName: String,
        isDepopulated: Bool,
        imageURL: URL?
    ) {
        self.regionId = regionId
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.isDepopulated = isDepopulated
        self.imageURL = imageURL
    }

    /// 화면 표시용 이름. "중구"처럼 겹치는 이름을 시·도로 구분한다. (예: "인천 중구")
    public var displayName: String { RegionNaming.displayName(sido: sidoName, sigungu: sigunguName) }
}

/// 관광지 결과 한 쪽. 지역과 달리 offset/limit으로 이어 받을 수 있다.
public struct SearchedPlacePage: Sendable {
    /// 검색어에 걸린 전체 개수. items.count와 다르다.
    public let total: Int
    public let limit: Int
    public let offset: Int
    public let items: [TaggedPlace]

    public init(total: Int, limit: Int, offset: Int, items: [TaggedPlace]) {
        self.total = total
        self.limit = limit
        self.offset = offset
        self.items = items
    }

    public static let empty = SearchedPlacePage(total: 0, limit: 0, offset: 0, items: [])

    /// 이 페이지까지 받고 나서 더 받을 게 남았는지.
    public var hasMore: Bool { offset + items.count < total }
}
