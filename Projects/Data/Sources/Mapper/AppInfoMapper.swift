import Domain

extension AppInfoDTO {
    func toEntity() -> AppInfo {
        AppInfo(
            appName: appName,
            latestVersion: latestVersion,
            minVersion: minVersion,
            forceUpdate: forceUpdate,
            updateAvailable: updateAvailable,
            updateMessage: updateMessage,
            storeUrl: storeUrl,
            maintenanceMode: maintenanceMode,
            maintenanceMessage: maintenanceMessage,
            serverTime: serverTime
        )
    }
}
