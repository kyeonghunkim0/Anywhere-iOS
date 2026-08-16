public struct FetchPassportUseCase: Sendable {
    private let passportRepository: PassportRepository

    public init(passportRepository: PassportRepository) {
        self.passportRepository = passportRepository
    }

    /// userId가 nil이면 내 여권을 조회한다.
    public func execute(userId: String?) async throws(NetworkError) -> Passport {
        if let userId {
            return try await passportRepository.fetchPassport(userId: userId)
        }
        return try await passportRepository.fetchMyPassport()
    }
}
