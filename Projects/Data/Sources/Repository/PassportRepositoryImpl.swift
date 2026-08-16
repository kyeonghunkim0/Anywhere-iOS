import Domain
final class PassportRepositoryImpl: PassportRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchMyPassport() async throws(NetworkError) -> Passport {
        do {
            let envelope = try await httpClient.request(PassportAPI.mine, as: APIResponse<PassportDTO>.self)
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }

    func fetchPassport(userId: String) async throws(NetworkError) -> Passport {
        do {
            let envelope = try await httpClient.request(PassportAPI.detail(userId: userId), as: APIResponse<PassportDTO>.self)
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
