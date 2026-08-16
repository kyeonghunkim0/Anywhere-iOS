public protocol QuestRepository: Sendable {
    /// 토큰이 있으면 자동으로 붙여 isAcquired를 채운다. 없어도 성공한다.
    func fetchQuests() async throws(NetworkError) -> [Quest]
    func claimQuest(questId: String, at coordinate: Coordinate) async throws(QuestError) -> ClaimedBadge
}
