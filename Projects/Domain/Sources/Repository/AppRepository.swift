public protocol AppRepository: Sendable {
    /// version/platform을 보내면 서버가 forceUpdate·storeUrl을 계산해 준다.
    func fetchAppInfo(version: String?, platform: String?) async throws(NetworkError) -> AppInfo
}
