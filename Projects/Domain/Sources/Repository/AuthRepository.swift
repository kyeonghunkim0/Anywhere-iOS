public protocol AuthRepository: Sendable {
    func login(with credential: SocialCredential) async throws(AuthError) -> AuthSession
}
