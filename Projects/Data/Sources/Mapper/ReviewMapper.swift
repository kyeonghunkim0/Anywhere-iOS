import Domain

extension ReviewDTO {
    func toEntity() -> Review {
        Review(id: id, content: content, createdAt: createdAt, placeId: placeId, placeName: placeName)
    }
}

extension PlaceReviewDTO {
    func toEntity() -> PlaceReview {
        PlaceReview(id: id, content: content, createdAt: createdAt, nickname: nickname)
    }
}
