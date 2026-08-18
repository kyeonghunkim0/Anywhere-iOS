struct LoginRequestDTO: Encodable, Sendable {
    /// "apple" | "google"
    let socialType: String
    /// 서버가 각 프로바이더 공개키로 직접 검증한다. socialId는 보내지 않는다.
    let idToken: String
    let nickname: String?
}
