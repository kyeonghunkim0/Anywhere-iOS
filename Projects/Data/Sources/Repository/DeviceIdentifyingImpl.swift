import Domain

final class DeviceIdentifyingImpl: DeviceIdentifying, Sendable {
    private let store: DeviceIdentifierStore

    init(store: DeviceIdentifierStore) {
        self.store = store
    }

    func currentDeviceId() async -> String {
        await store.currentDeviceId()
    }
}
