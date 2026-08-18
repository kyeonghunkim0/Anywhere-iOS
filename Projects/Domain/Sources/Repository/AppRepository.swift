public protocol AppRepository: Sendable {
    /// version을 보내면 서버가 forceUpdate 여부를 계산해 준다.
    func fetchAppInfo(version: String?) async throws(NetworkError) -> AppInfo
}
