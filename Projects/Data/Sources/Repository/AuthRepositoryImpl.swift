import Domain
final class AuthRepositoryImpl: AuthRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func login(with credential: SocialCredential) async throws(AuthError) -> AuthSession {
        let request = LoginRequestDTO(
            socialType: credential.socialType.rawValue,
            socialId: credential.socialId,
            nickname: credential.nickname,
            profileImage: credential.profileImageURL?.absoluteString
        )
        do {
            let envelope = try await httpClient.request(AuthAPI.login(request), as: APIResponse<LoginDataDTO>.self)
            // 신규 가입 여부는 응답 본문이 아니라 HTTP 201/200으로만 알 수 있다.
            let isNewUser = envelope.statusCode == 201
            return AuthSession(
                token: envelope.value.data.token,
                user: envelope.value.data.user.toEntity(),
                isNewUser: isNewUser
            )
        } catch {
            throw ErrorMapper.auth(error)
        }
    }

    func fetchMyProfile() async throws(AuthError) -> UserProfile {
        do {
            let envelope = try await httpClient.request(AuthAPI.me, as: APIResponse<UserProfileDTO>.self)
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.auth(error)
        }
    }
}
