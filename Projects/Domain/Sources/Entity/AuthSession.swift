public struct AuthSession: Sendable {
    public let token: String
    public let user: User
    /// POST /api/auth/login 응답 본문엔 없다. HTTP 201/200 여부로 Data가 채워 넣는다.
    public let isNewUser: Bool

    public init(token: String, user: User, isNewUser: Bool) {
        self.token = token
        self.user = user
        self.isNewUser = isNewUser
    }
}
