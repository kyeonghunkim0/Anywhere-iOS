public struct FetchPassportUseCase: Sendable {
    private let passportRepository: PassportRepository

    public init(passportRepository: PassportRepository) {
        self.passportRepository = passportRepository
    }

    public func execute(userId: String) async throws(NetworkError) -> Passport {
        try await passportRepository.fetchPassport(userId: userId)
    }
}
