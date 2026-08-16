struct LoginRequestDTO: Encodable, Sendable {
    let socialType: String
    let socialId: String
    let nickname: String?
    let profileImage: String?
}
