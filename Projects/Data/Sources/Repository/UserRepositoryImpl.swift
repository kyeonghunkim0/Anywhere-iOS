import Domain

final class UserRepositoryImpl: UserRepository, Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchMyProfile() async throws(AuthError) -> UserProfile {
        do {
            let envelope = try await httpClient.request(UserAPI.me, as: APIResponse<UserProfileDTO>.self)
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.auth(error)
        }
    }

    func fetchMyStats() async throws(NetworkError) -> ProfileStats {
        do {
            let envelope = try await httpClient.request(UserAPI.stats, as: APIResponse<ProfileStatsDTO>.self)
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }

    func updateProfile(nickname: String?, profileImage: String?) async throws(ProfileError) -> UserProfile {
        let request = UpdateProfileRequestDTO(nickname: nickname, profileImage: profileImage)
        do {
            let envelope = try await httpClient.request(
                UserAPI.updateProfile(request),
                as: APIResponse<UserProfileDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.profile(error)
        }
    }

    func updateSettings(pushEnabled: Bool) async throws(ProfileError) -> UserProfile {
        let request = UpdateSettingsRequestDTO(pushEnabled: pushEnabled)
        do {
            let envelope = try await httpClient.request(
                UserAPI.updateSettings(request),
                as: APIResponse<UserProfileDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.profile(error)
        }
    }

    func fetchRankerDetail(userId: String) async throws(NetworkError) -> RankerDetail {
        do {
            let envelope = try await httpClient.request(
                UserAPI.detail(userId: userId),
                as: APIResponse<RankerDetailDTO>.self
            )
            return envelope.value.data.toEntity()
        } catch {
            throw ErrorMapper.network(error)
        }
    }
}
