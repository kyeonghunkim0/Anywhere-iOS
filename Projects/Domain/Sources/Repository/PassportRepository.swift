public protocol PassportRepository: Sendable {
    /// 내 여권도 내 userId로 조회한다 — 서버에 "나" 전용 경로는 없다.
    func fetchPassport(userId: String) async throws(NetworkError) -> Passport
}
