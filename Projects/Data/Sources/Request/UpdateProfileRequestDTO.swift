/// nickname이 nil이면 인코딩에서 빠져 서버가 기존 값을 유지한다.
struct UpdateProfileRequestDTO: Encodable, Sendable {
    let nickname: String?
}

struct UpdateSettingsRequestDTO: Encodable, Sendable {
    let pushEnabled: Bool
}
