public struct CheckInResult: Sendable {
    public let message: String
    public let stamp: StampResult
    /// 이번 체크인으로 자동 획득한 로컬 히든 뱃지. 서버가 반경 안에 들어왔는지 판정해 지급한다
    /// — 클라이언트가 따로 수집(claim)을 요청하는 API는 없다.
    public let newBadges: [EarnedBadge]

    public init(message: String, stamp: StampResult, newBadges: [EarnedBadge]) {
        self.message = message
        self.stamp = stamp
        self.newBadges = newBadges
    }
}

/// 체크인 응답에 실려 오는 축약된 뱃지 정보.
public struct EarnedBadge: Sendable, Identifiable, Equatable {
    public let id: String
    public let key: String
    public let name: String
    public let icon: String

    public init(id: String, key: String, name: String, icon: String) {
        self.id = id
        self.key = key
        self.name = name
        self.icon = icon
    }
}
