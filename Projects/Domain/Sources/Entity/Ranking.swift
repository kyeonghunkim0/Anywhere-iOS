/// GET /api/ranking/users — 누적 도장 수 기준 TOP 10.
public struct UserRankItem: Sendable, Identifiable, Equatable {
    public var id: String { userId }
    public let rank: Int
    public let userId: String
    public let nickname: String
    public let totalStamps: Int

    public init(rank: Int, userId: String, nickname: String, totalStamps: Int) {
        self.rank = rank
        self.userId = userId
        self.nickname = nickname
        self.totalStamps = totalStamps
    }
}

/// GET /api/ranking/places — 최근 1주일 인기 지역 TOP 10.
public struct PlaceRankItem: Sendable, Identifiable, Equatable {
    public var id: String { regionId }
    public let rank: Int
    public let regionId: String
    public let sidoName: String
    public let sigunguName: String
    public let isDepopulated: Bool
    public let visitCount: Int

    public init(
        rank: Int,
        regionId: String,
        sidoName: String,
        sigunguName: String,
        isDepopulated: Bool,
        visitCount: Int
    ) {
        self.rank = rank
        self.regionId = regionId
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.isDepopulated = isDepopulated
        self.visitCount = visitCount
    }

    public var fullName: String { "\(sidoName) \(sigunguName)" }

    /// 화면 표시용 이름. "중구"처럼 겹치는 이름을 시·도로 구분한다. (예: "인천 중구")
    public var displayName: String { RegionNaming.displayName(sido: sidoName, sigungu: sigunguName) }
}

/// GET /api/ranking/me.
public struct MyRank: Sendable, Equatable {
    public let rank: Int
    public let totalUsers: Int
    public let userId: String
    public let nickname: String
    public let totalStamps: Int
    /// 상위 N%.
    public let topPercentage: Double

    public init(rank: Int, totalUsers: Int, userId: String, nickname: String, totalStamps: Int, topPercentage: Double) {
        self.rank = rank
        self.totalUsers = totalUsers
        self.userId = userId
        self.nickname = nickname
        self.totalStamps = totalStamps
        self.topPercentage = topPercentage
    }
}
