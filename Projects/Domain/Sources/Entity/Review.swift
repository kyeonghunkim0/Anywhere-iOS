import Foundation

/// POST /api/reviews 응답.
public struct Review: Sendable, Identifiable, Equatable {
    public let id: String
    public let content: String
    public let createdAt: Date
    public let placeId: String
    public let placeName: String

    public init(id: String, content: String, createdAt: Date, placeId: String, placeName: String) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.placeId = placeId
        self.placeName = placeName
    }
}

/// GET /api/reviews/places/{placeId} — 목록에는 작성자 닉네임만 온다.
public struct PlaceReview: Sendable, Identifiable, Equatable {
    public let id: String
    public let content: String
    public let createdAt: Date
    public let nickname: String

    public init(id: String, content: String, createdAt: Date, nickname: String) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.nickname = nickname
    }
}
