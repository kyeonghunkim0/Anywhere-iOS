public protocol BadgeRepository: Sendable {
    /// 내 스페셜(시즌 한정) & 로컬 히든 뱃지 전체 현황.
    func fetchMyBadges() async throws(NetworkError) -> [Badge]
    /// 홈 [스페셜 퀘스트] 캐러셀용 — 진행 중인 시즌 한정 뱃지 (인증 불필요).
    func fetchSeasonalBadges() async throws(NetworkError) -> [Badge]
}
