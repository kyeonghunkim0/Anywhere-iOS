import Foundation

/// 게스트 로그인용 기기 식별자. `identifierForVendor`는 삭제 후 재설치 시 값이 바뀔 수 있어
/// 대신 Keychain에 자체 생성한 UUID를 보관한다.
actor DeviceIdentifierStore {
    private let storage: KeychainStorage
    private let key = "deviceId"
    private var cachedId: String?

    init(storage: KeychainStorage = KeychainStorage()) {
        self.storage = storage
        self.cachedId = storage.load(for: key)
    }

    func currentDeviceId() -> String {
        if let cachedId {
            return cachedId
        }
        let newId = UUID().uuidString
        cachedId = newId
        storage.save(newId, for: key)
        return newId
    }
}
