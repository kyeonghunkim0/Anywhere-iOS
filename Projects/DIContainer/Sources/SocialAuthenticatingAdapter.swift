import Auth
import Domain
import UIKit

/// Domain은 UIKit을 몰라야 하므로, AuthProvider가 요구하는 UIViewController를
/// 여기서 활성 window scene으로부터 직접 찾아 흡수한다.
struct SocialAuthenticatingAdapter: SocialAuthenticating {
    private let authProvider = AuthProvider()

    func signIn(with socialType: SocialType) async throws(SocialAuthenticationError) -> SocialCredential {
        guard let viewController = await Self.topViewController() else {
            throw .failed
        }

        do {
            let result: SocialSignInResult
            switch socialType {
            case .google:
                result = try await authProvider.signInWithGoogle(presenting: viewController)
            case .apple:
                result = try await authProvider.signInWithApple(presenting: viewController)
            case .kakao:
                // 카카오 SDK는 아직 연동되지 않았다.
                throw SocialAuthenticationError.failed
            }
            return SocialCredential(
                socialType: socialType,
                socialId: result.socialId,
                nickname: result.nickname,
                profileImageURL: result.profileImageURL
            )
        } catch let error as SocialAuthenticationError {
            throw error
        } catch is CancellationError {
            throw .cancelled
        } catch {
            throw .failed
        }
    }

    func signOut() async {
        // Firebase 세션 자체는 유지해도 무방하다 — 서버 JWT만 지우면
        // 다음 로그인 시 AuthProvider가 다시 자격 증명을 만들어 준다.
    }

    @MainActor
    private static func topViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: \.isKeyWindow)?.rootViewController
    }
}
