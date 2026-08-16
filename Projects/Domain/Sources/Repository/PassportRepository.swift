public protocol PassportRepository: Sendable {
    func fetchMyPassport() async throws(NetworkError) -> Passport
    func fetchPassport(userId: String) async throws(NetworkError) -> Passport
}
