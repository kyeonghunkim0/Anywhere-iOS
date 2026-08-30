import Foundation

public struct Region: Sendable, Identifiable, Hashable {
    public let id: String
    public let sidoName: String
    public let sigunguName: String
    public let isDepopulated: Bool

    public init(id: String, sidoName: String, sigunguName: String, isDepopulated: Bool) {
        self.id = id
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.isDepopulated = isDepopulated
    }

    public var fullName: String { "\(sidoName) \(sigunguName)" }

    /// 화면 표시용 이름. "중구"처럼 겹치는 이름을 시·도로 구분한다. (예: "인천 중구")
    public var displayName: String { RegionNaming.displayName(sido: sidoName, sigungu: sigunguName) }
}

/// GET /api/regions/growth — 레벨업이 임박한 인구감소지역.
public struct GrowthRegion: Sendable, Identifiable, Equatable {
    public var id: String { regionId }
    public let regionId: String
    public let sidoName: String
    public let sigunguName: String
    public let isDepopulated: Bool
    public let level: Int
    /// 현재 누적 방문 수.
    public let current: Int
    /// 다음 레벨까지 필요한 누적 방문 수.
    public let target: Int
    public let remaining: Int

    public init(
        regionId: String,
        sidoName: String,
        sigunguName: String,
        isDepopulated: Bool,
        level: Int,
        current: Int,
        target: Int,
        remaining: Int
    ) {
        self.regionId = regionId
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.isDepopulated = isDepopulated
        self.level = level
        self.current = current
        self.target = target
        self.remaining = remaining
    }

    public var fullName: String { "\(sidoName) \(sigunguName)" }

    /// 화면 표시용 이름. "중구"처럼 겹치는 이름을 시·도로 구분한다. (예: "인천 중구")
    public var displayName: String { RegionNaming.displayName(sido: sidoName, sigungu: sigunguName) }
}

public struct RegionLevelRow: Sendable, Identifiable, Equatable {
    public var id: Int { level }
    public let level: Int
    public let label: String
    public let reward: String
    public let achieved: Bool

    public init(level: Int, label: String, reward: String, achieved: Bool) {
        self.level = level
        self.label = label
        self.reward = reward
        self.achieved = achieved
    }
}

/// GET /api/regions/{regionId} — 지역 상세(레벨, 성장 게이지, 통계, 레벨 보상 현황).
public struct RegionDetail: Sendable, Identifiable {
    public var id: String { regionId }
    public let regionId: String
    public let sidoName: String
    public let sigunguName: String
    public let isDepopulated: Bool
    public let level: Int
    public let current: Int
    /// 최고 레벨을 달성하면 서버가 null로 내려준다.
    public let target: Int?
    /// "5.3%" 등 progress bar 표시용 문자열.
    public let progressLabel: String
    /// "15명만 더 오면 레벨업!" 또는 최고 레벨 문구.
    public let remainLabel: String
    /// 주민 한마디. 없을 수 있다.
    public let quote: String?
    /// 지역 대표 사진과 그 저작자. 서버가 한국관광공사 이미지를 내려준다.
    public let imageURL: URL?
    public let imageCredit: String?
    public let stats: [LabeledValue]
    public let levels: [RegionLevelRow]

    public init(
        regionId: String,
        sidoName: String,
        sigunguName: String,
        isDepopulated: Bool,
        level: Int,
        current: Int,
        target: Int?,
        progressLabel: String,
        remainLabel: String,
        quote: String?,
        imageURL: URL?,
        imageCredit: String?,
        stats: [LabeledValue],
        levels: [RegionLevelRow]
    ) {
        self.regionId = regionId
        self.sidoName = sidoName
        self.sigunguName = sigunguName
        self.isDepopulated = isDepopulated
        self.level = level
        self.current = current
        self.target = target
        self.progressLabel = progressLabel
        self.remainLabel = remainLabel
        self.quote = quote
        self.imageURL = imageURL
        self.imageCredit = imageCredit
        self.stats = stats
        self.levels = levels
    }

    public var fullName: String { "\(sidoName) \(sigunguName)" }

    /// 화면 표시용 이름. "중구"처럼 겹치는 이름을 시·도로 구분한다. (예: "인천 중구")
    public var displayName: String { RegionNaming.displayName(sido: sidoName, sigungu: sigunguName) }
}
