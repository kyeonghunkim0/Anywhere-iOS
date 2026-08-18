public protocol UserRepository: Sendable {
    /// 토큰 만료 시 .sessionExpired를 던진다 — 세션 복원 판단에 쓰인다.
    func fetchMyProfile() async throws(AuthError) -> UserProfile
    func fetchMyStats() async throws(NetworkError) -> ProfileStats
    /// nil인 항목은 요청 본문에서 아예 빠져 서버가 기존 값을 유지한다.
    func updateProfile(nickname: String?, profileImage: String?) async throws(ProfileError) -> UserProfile
    func updateSettings(pushEnabled: Bool) async throws(ProfileError) -> UserProfile
    func fetchRankerDetail(userId: String) async throws(NetworkError) -> RankerDetail
}
