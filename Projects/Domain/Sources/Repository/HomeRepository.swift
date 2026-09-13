public protocol HomeRepository: Sendable {
    /// 홈 화면 데이터 전체(여정/뱃지/지역/섹션 노출 여부)를 한 번에 가져온다.
    func fetchHome() async throws(NetworkError) -> HomeSnapshot
}
