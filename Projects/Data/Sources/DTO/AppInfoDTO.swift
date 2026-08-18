import Foundation

/// GET /api/app/info.
struct AppInfoDTO: Decodable, Sendable {
    let appName: String
    let latestVersion: String
    let minVersion: String
    let forceUpdate: Bool
    let maintenanceMode: Bool
    let maintenanceMessage: String?
    let serverTime: Date
}
