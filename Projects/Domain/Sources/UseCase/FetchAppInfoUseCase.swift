public struct FetchAppInfoUseCase: Sendable {
    private let appRepository: AppRepository

    public init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }

    public func execute(version: String?) async throws(NetworkError) -> AppInfo {
        try await appRepository.fetchAppInfo(version: version)
    }
}
