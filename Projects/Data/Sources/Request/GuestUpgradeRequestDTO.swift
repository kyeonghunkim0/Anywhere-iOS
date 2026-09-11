/// LoginRequestDTO와 같은 필드. 게스트 토큰으로 인증된 상태에서 소셜 계정을 연결한다.
struct GuestUpgradeRequestDTO: Encodable, Sendable {
    let socialType: String
    let idToken: String
    let nickname: String?
}
