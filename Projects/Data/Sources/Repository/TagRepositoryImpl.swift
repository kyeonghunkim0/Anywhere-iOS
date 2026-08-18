import Domain

final class TagRepositoryImpl: TagRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchTags() async throws(NetworkError) -> [CurationTag] {
        do {
            let envelope = try await httpClient.request(TagAPI.list, as: APIResponse<[CurationTagDTO]>.self)
            return envelope.value.data.map { $0.toEntity() }
        } catch {
            throw ErrorMapper.network(error)
        }
    }

    func fetchPlaces(tagId: String) async throws(NetworkError) -> [TaggedPlace] {
        do {
            let envelope = try await httpClient.request(
                TagAPI.places(tagId: tagId),
                as: APIResponse<[TaggedPlaceDTO]>.self
            )
            return envelope.value.data.map { $0.toEntity() }
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
