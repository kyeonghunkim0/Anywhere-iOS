import Foundation

/// GET /api/app/info — 앱 최초 실행 시 강제 업데이트/점검 여부 확인.
public struct AppInfo: Sendable, Equatable {
    public let appName: String
    public let latestVersion: String
    public let minVersion: String
    /// 요청에 실어 보낸 버전이 minVersion보다 낮을 때만 true.
    public let forceUpdate: Bool
    public let maintenanceMode: Bool
    public let maintenanceMessage: String?
    public let serverTime: Date

    public init(
        appName: String,
        latestVersion: String,
        minVersion: String,
        forceUpdate: Bool,
        maintenanceMode: Bool,
        maintenanceMessage: String?,
        serverTime: Date
    ) {
        self.appName = appName
        self.latestVersion = latestVersion
        self.minVersion = minVersion
        self.forceUpdate = forceUpdate
        self.maintenanceMode = maintenanceMode
        self.maintenanceMessage = maintenanceMessage
        self.serverTime = serverTime
    }
}
