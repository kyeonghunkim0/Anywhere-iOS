import Domain

final class PlaceRepositoryImpl: PlaceRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchPlaceDetail(placeId: String) async throws(NetworkError) -> PlaceDetail {
        do {
            let envelope = try await httpClient.request(
                PlaceAPI.detail(placeId: placeId),
                as: APIResponse<PlaceDetailDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
