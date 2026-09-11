public struct SignInAsGuestUseCase: Sendable {
    private let deviceIdentifying: DeviceIdentifying
    private let authRepository: AuthRepository
    private let sessionRepository: SessionRepository

    public init(
        deviceIdentifying: DeviceIdentifying,
        authRepository: AuthRepository,
        sessionRepository: SessionRepository
    ) {
        self.deviceIdentifying = deviceIdentifying
        self.authRepository = authRepository
        self.sessionRepository = sessionRepository
    }

    public func execute() async throws(AuthError) -> AuthSession {
        let deviceId = await deviceIdentifying.currentDeviceId()
        let session = try await authRepository.loginAsGuest(deviceId: deviceId)
        await sessionRepository.saveToken(session.token)
        return session
    }
}
