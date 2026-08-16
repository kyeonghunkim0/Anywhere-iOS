import Foundation

public struct Place: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let address: String
    public let thumbnailURL: URL?
    public let coordinate: Coordinate
    public let distanceKm: Double
    public let localRecommendation: String
    public let tags: [String]

    public init(
        id: String,
        name: String,
        address: String,
        thumbnailURL: URL?,
        coordinate: Coordinate,
        distanceKm: Double,
        localRecommendation: String,
        tags: [String]
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.thumbnailURL = thumbnailURL
        self.coordinate = coordinate
        self.distanceKm = distanceKm
        self.localRecommendation = localRecommendation
        self.tags = tags
    }
}
