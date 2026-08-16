public protocol AuthRepository: Sendable {
    func login(with credential: SocialCredential) async throws(AuthError) -> AuthSession
    func fetchMyProfile() async throws(AuthError) -> UserProfile
}
