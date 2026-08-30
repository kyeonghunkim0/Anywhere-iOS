public protocol PlaceRepository: Sendable {
    func fetchPlaceDetail(placeId: String) async throws(NetworkError) -> PlaceDetail
}
