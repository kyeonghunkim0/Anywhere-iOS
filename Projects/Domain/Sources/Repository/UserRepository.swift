public protocol UserRepository: Sendable {
    /// 토큰 만료 시 .sessionExpired를 던진다 — 세션 복원 판단에 쓰인다.
    func fetchMyProfile() async throws(AuthError) -> UserProfile
    func fetchMyStats() async throws(NetworkError) -> ProfileStats
    /// nickname이 nil이면 요청 본문에서 빠져 서버가 기존 값을 유지한다.
    func updateProfile(nickname: String?) async throws(ProfileError) -> UserProfile
    func updateSettings(pushEnabled: Bool) async throws(ProfileError) -> UserProfile
    func fetchRankerDetail(userId: String) async throws(NetworkError) -> RankerDetail
    /// 토큰 만료 시 .sessionExpired를 던진다 — fetchMyProfile과 같은 판단 기준을 쓴다.
    func deleteMyAccount() async throws(AuthError)
    func blockUser(userId: String) async throws(UserError)
    func unblockUser(userId: String) async throws(UserError)
    /// 최신 차단순, 페이지네이션 없음.
    func fetchBlockedUsers() async throws(NetworkError) -> [BlockedUser]
}
