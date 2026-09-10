import Foundation

/// GET /api/app/info — 앱 최초 실행 시 강제 업데이트/점검 여부 확인.
public struct AppInfo: Sendable, Equatable {
    public let appName: String
    public let latestVersion: String
    public let minVersion: String
    /// 요청에 실어 보낸 버전이 minVersion보다 낮을 때만 true.
    public let forceUpdate: Bool
    /// 요청 버전이 latestVersion보다 낮을 때 true (선택 업데이트).
    public let updateAvailable: Bool
    /// forceUpdate/updateAvailable가 true일 때 서버가 주는 안내 문구.
    public let updateMessage: String?
    /// platform에 맞는 스토어 링크.
    public let storeUrl: String?
    public let maintenanceMode: Bool
    public let maintenanceMessage: String?
    public let serverTime: Date

    public init(
        appName: String,
        latestVersion: String,
        minVersion: String,
        forceUpdate: Bool,
        updateAvailable: Bool,
        updateMessage: String?,
        storeUrl: String?,
        maintenanceMode: Bool,
        maintenanceMessage: String?,
        serverTime: Date
    ) {
        self.appName = appName
        self.latestVersion = latestVersion
        self.minVersion = minVersion
        self.forceUpdate = forceUpdate
        self.updateAvailable = updateAvailable
        self.updateMessage = updateMessage
        self.storeUrl = storeUrl
        self.maintenanceMode = maintenanceMode
        self.maintenanceMessage = maintenanceMessage
        self.serverTime = serverTime
    }
}
