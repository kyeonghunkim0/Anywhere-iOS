public protocol ReviewRepository: Sendable {
    func reportReview(reviewId: String, reason: ReportReason, detail: String?) async throws(ReviewError)
    func createReview(placeId: String, content: String) async throws(ReviewError) -> Review
    /// limit 생략 시 서버 기본값 20.
    func fetchReviews(placeId: String, limit: Int?) async throws(NetworkError) -> [PlaceReview]
}
