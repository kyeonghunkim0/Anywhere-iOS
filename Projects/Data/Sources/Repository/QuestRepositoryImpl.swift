import Domain
final class QuestRepositoryImpl: QuestRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchQuests() async throws(NetworkError) -> [Quest] {
        do {
            let envelope = try await httpClient.request(QuestAPI.list, as: APIResponse<[QuestDTO]>.self)
            return envelope.value.data.map { $0.toEntity() }
        } catch {
            throw ErrorMapper.network(error)
        }
    }

    func claimQuest(questId: String, at coordinate: Coordinate) async throws(QuestError) -> ClaimedBadge {
        let request = ClaimQuestRequestDTO(lat: coordinate.latitude, lng: coordinate.longitude)
        do {
            let envelope = try await httpClient.request(
                QuestAPI.claim(questId: questId, request: request),
                as: APIResponse<ClaimQuestDataDTO>.self
            )
            return envelope.value.data.badge.toEntity()
        } catch {
            throw ErrorMapper.quest(error)
        }
    }
}
