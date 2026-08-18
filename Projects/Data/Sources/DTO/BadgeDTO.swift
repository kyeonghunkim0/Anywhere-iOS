import Foundation

/// GET /api/badges/me, GET /api/badges/seasonal.
struct BadgeDTO: Decodable, Sendable {
    let id: String
    let key: String
    let name: String
    let description: String
    let icon: String
    /// "SEASONAL" | "HIDDEN" | "REGION"
    let type: String
    /// "EARNED" | "AVAILABLE" | "EXPIRED"
    let status: String
    let earnedAt: Date?
    let daysRemaining: Int?
    let isLocationHidden: Bool
    let lat: Double?
    let lng: Double?
    let radiusM: Double?
    let regionId: String?
    let placeId: String?
}
