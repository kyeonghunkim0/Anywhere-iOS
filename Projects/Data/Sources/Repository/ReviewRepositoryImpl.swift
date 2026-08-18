import Domain

final class ReviewRepositoryImpl: ReviewRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func createReview(placeId: String, content: String) async throws(ReviewError) -> Review {
        let request = CreateReviewRequestDTO(placeId: placeId, content: content)
        do {
            let envelope = try await httpClient.request(ReviewAPI.create(request), as: APIResponse<ReviewDTO>.self)
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.review(error)
        }
    }

    func fetchReviews(placeId: String, limit: Int?) async throws(NetworkError) -> [PlaceReview] {
        do {
            let envelope = try await httpClient.request(
                ReviewAPI.byPlace(placeId: placeId, limit: limit),
                as: APIResponse<[PlaceReviewDTO]>.self
            )
            return envelope.value.data.map { $0.toEntity() }
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
