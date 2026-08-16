public struct SignOutUseCase: Sendable {
    private let socialAuthenticating: SocialAuthenticating
    private let sessionRepository: SessionRepository

    public init(socialAuthenticating: SocialAuthenticating, sessionRepository: SessionRepository) {
        self.socialAuthenticating = socialAuthenticating
        self.sessionRepository = sessionRepository
    }

    public func execute() async {
        await socialAuthenticating.signOut()
        await sessionRepository.clearToken()
    }
}
