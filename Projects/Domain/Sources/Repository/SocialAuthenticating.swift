public enum SocialAuthenticationError: Error, Sendable {
    case cancelled
    case failed
}

/// Auth 모듈(Firebase/GoogleSignIn/AppleID)을 UIKit 없이 감싸는 경계.
/// UIViewController를 요구하지 않는다 — presenting 책임은 DIContainer 어댑터가 흡수한다.
public protocol SocialAuthenticating: Sendable {
    func signIn(with socialType: SocialType) async throws(SocialAuthenticationError) -> SocialCredential
    func signOut() async
}
