public struct FetchPlaceDetailUseCase: Sendable {
    private let placeRepository: PlaceRepository

    public init(placeRepository: PlaceRepository) {
        self.placeRepository = placeRepository
    }

    public func execute(placeId: String) async throws(NetworkError) -> PlaceDetail {
        try await placeRepository.fetchPlaceDetail(placeId: placeId)
    }
}
