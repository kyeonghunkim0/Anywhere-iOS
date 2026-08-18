/// nil인 필드는 인코딩에서 빠져 서버가 기존 값을 유지한다.
struct UpdateProfileRequestDTO: Encodable, Sendable {
    let nickname: String?
    let profileImage: String?
}

struct UpdateSettingsRequestDTO: Encodable, Sendable {
    let pushEnabled: Bool
}
