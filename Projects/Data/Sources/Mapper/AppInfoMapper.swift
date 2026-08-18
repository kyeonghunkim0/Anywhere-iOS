import Domain

extension AppInfoDTO {
    func toEntity() -> AppInfo {
        AppInfo(
            appName: appName,
            latestVersion: latestVersion,
            minVersion: minVersion,
            forceUpdate: forceUpdate,
            maintenanceMode: maintenanceMode,
            maintenanceMessage: maintenanceMessage,
            serverTime: serverTime
        )
    }
}
