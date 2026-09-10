import Foundation

/// GET /api/app/info.
struct AppInfoDTO: Decodable, Sendable {
    let appName: String
    let latestVersion: String
    let minVersion: String
    let forceUpdate: Bool
    /// 요청 버전이 latestVersion보다 낮을 때 true (선택 업데이트).
    let updateAvailable: Bool
    /// forceUpdate/updateAvailable가 true일 때 서버가 내려주는 안내 문구.
    let updateMessage: String?
    /// platform에 맞는 스토어 링크.
    let storeUrl: String?
    let maintenanceMode: Bool
    let maintenanceMessage: String?
    let serverTime: Date
}
