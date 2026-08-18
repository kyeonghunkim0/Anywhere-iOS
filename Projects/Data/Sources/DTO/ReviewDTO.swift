import Foundation

/// POST /api/reviews.
struct ReviewDTO: Decodable, Sendable {
    let id: String
    let content: String
    let createdAt: Date
    let placeId: String
    let placeName: String
}

/// GET /api/reviews/places/{placeId}.
struct PlaceReviewDTO: Decodable, Sendable {
    let id: String
    let content: String
    let createdAt: Date
    let nickname: String
}
