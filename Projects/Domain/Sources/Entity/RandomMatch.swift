import Foundation

public struct MatchInfo: Sendable, Equatable {
    /// 오늘 남은 매칭 횟수 (하루 3회 제한).
    public let remainingMatches: Int
    public let isDepopulatedBonus: Bool

    public init(remainingMatches: Int, isDepopulatedBonus: Bool) {
        self.remainingMatches = remainingMatches
        self.isDepopulatedBonus = isDepopulatedBonus
    }
}

/// GET /api/match/random — 아직 확정되지 않은 매칭 후보.
public struct RandomMatch: Sendable, Identifiable {
    public var id: String { matchId }
    /// "여기로 결정"(confirm) / "여정 취소"(cancel)에 쓰는 매칭 이력 ID.
    public let matchId: String
    public let place: Place
    public let distanceKm: Double
    public let region: Region
    public let matchInfo: MatchInfo

    public init(matchId: String, place: Place, distanceKm: Double, region: Region, matchInfo: MatchInfo) {
        self.matchId = matchId
        self.place = place
        self.distanceKm = distanceKm
        self.region = region
        self.matchInfo = matchInfo
    }
}

/// GET /api/match/current, POST /api/match/{matchId}/confirm — 확정됐지만 아직 체크인하지 않은 여정.
public struct CurrentTrip: Sendable, Identifiable {
    public var id: String { matchId }
    public let matchId: String
    public let distanceKm: Double
    public let confirmedAt: Date
    public let place: Place
    public let region: Region

    public init(matchId: String, distanceKm: Double, confirmedAt: Date, place: Place, region: Region) {
        self.matchId = matchId
        self.distanceKm = distanceKm
        self.confirmedAt = confirmedAt
        self.place = place
        self.region = region
    }
}
