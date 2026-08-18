import Foundation

public enum BadgeType: String, Sendable, Equatable {
    case seasonal = "SEASONAL"
    case hidden = "HIDDEN"
    case region = "REGION"
}

public enum BadgeStatus: String, Sendable, Equatable {
    case earned = "EARNED"
    case available = "AVAILABLE"
    case expired = "EXPIRED"
}

/// GET /api/badges/me, GET /api/badges/seasonal.
public struct Badge: Sendable, Identifiable {
    public let id: String
    public let key: String
    public let name: String
    public let description: String
    /// 서버가 정한 아이콘 식별자 문자열 (URL이 아니다).
    public let icon: String
    public let type: BadgeType
    public let status: BadgeStatus
    public let earnedAt: Date?
    /// 시즌 한정 뱃지 마감까지 남은 일수. 음수면 마감.
    public let daysRemaining: Int?
    /// 히든 뱃지를 아직 못 얻었으면 서버가 좌표를 감춘다 (coordinate/radiusM이 nil).
    public let isLocationHidden: Bool
    public let coordinate: Coordinate?
    public let radiusM: Double?
    public let regionId: String?
    public let placeId: String?

    public init(
        id: String,
        key: String,
        name: String,
        description: String,
        icon: String,
        type: BadgeType,
        status: BadgeStatus,
        earnedAt: Date?,
        daysRemaining: Int?,
        isLocationHidden: Bool,
        coordinate: Coordinate?,
        radiusM: Double?,
        regionId: String?,
        placeId: String?
    ) {
        self.id = id
        self.key = key
        self.name = name
        self.description = description
        self.icon = icon
        self.type = type
        self.status = status
        self.earnedAt = earnedAt
        self.daysRemaining = daysRemaining
        self.isLocationHidden = isLocationHidden
        self.coordinate = coordinate
        self.radiusM = radiusM
        self.regionId = regionId
        self.placeId = placeId
    }
}
