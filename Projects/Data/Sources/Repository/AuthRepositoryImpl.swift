import Domain

final class AuthRepositoryImpl: AuthRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func login(with credential: SocialCredential) async throws(AuthError) -> AuthSession {
        let request = LoginRequestDTO(
            socialType: credential.socialType.rawValue,
            idToken: credential.idToken,
            nickname: credential.nickname
        )
        do {
            let envelope = try await httpClient.request(AuthAPI.login(request), as: APIResponse<LoginDataDTO>.self)
            // 신규 가입 여부는 응답 본문이 아니라 HTTP 201/200으로만 알 수 있다.
            return AuthSession(
                token: envelope.value.data.token,
                user: envelope.value.data.user.toEntity(),
                isNewUser: envelope.statusCode == 201
            )
        } catch {
            throw ErrorMapper.auth(error)
        }
    }
}
