/// 게스트 로그인에 쓰는 기기 식별자의 경계. 앱 삭제/재설치에도 값이 유지되도록
/// Data가 Keychain에 보관한다 — `identifierForVendor`는 재설치 시 바뀔 수 있어 쓰지 않는다.
public protocol DeviceIdentifying: Sendable {
    func currentDeviceId() async -> String
}
