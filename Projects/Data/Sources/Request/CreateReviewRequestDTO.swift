struct CreateReviewRequestDTO: Encodable, Sendable {
    let placeId: String
    let content: String
}
