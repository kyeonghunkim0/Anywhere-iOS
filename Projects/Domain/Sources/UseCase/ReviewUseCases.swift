public struct CreateReviewUseCase: Sendable {
    private let reviewRepository: ReviewRepository

    public init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    public func execute(placeId: String, content: String) async throws(ReviewError) -> Review {
        try await reviewRepository.createReview(placeId: placeId, content: content)
    }
}

public struct ReportReviewUseCase: Sendable {
    private let reviewRepository: ReviewRepository

    public init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    public func execute(reviewId: String, reason: ReportReason, detail: String? = nil) async throws(ReviewError) {
        try await reviewRepository.reportReview(reviewId: reviewId, reason: reason, detail: detail)
    }
}

public struct FetchPlaceReviewsUseCase: Sendable {
    private let reviewRepository: ReviewRepository

    public init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    public func execute(placeId: String, limit: Int? = nil) async throws(NetworkError) -> [PlaceReview] {
        try await reviewRepository.fetchReviews(placeId: placeId, limit: limit)
    }
}
