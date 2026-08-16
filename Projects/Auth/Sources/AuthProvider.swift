import AuthenticationServices
import FirebaseAuth
import GoogleSignIn
import UIKit

/// Google, Apple 로그인을 모두 Firebase Auth 세션으로 통일해서 반환합니다.
/// 프로바이더별 SDK 토큰은 여기서만 다루고, 바깥에서는 항상 FirebaseAuth.User만 보게 됩니다.
@MainActor
public struct AuthProvider {
    public init() {}

    @discardableResult
    public func signInWithGoogle(presenting viewController: UIViewController) async throws -> SocialSignInResult {
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthProviderError.missingGoogleIDToken
        }
        guard let googleUserID = result.user.userID else {
            throw AuthProviderError.missingGoogleUserID
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        let firebaseUser = try await Auth.auth().signIn(with: credential).user

        return SocialSignInResult(
            socialId: googleUserID,
            nickname: firebaseUser.displayName ?? result.user.profile?.name,
            profileImageURL: firebaseUser.photoURL ?? result.user.profile?.imageURL(withDimension: 200)
        )
    }

    @discardableResult
    public func signInWithApple(presenting viewController: UIViewController) async throws -> SocialSignInResult {
        guard let anchor = viewController.view.window else {
            throw AuthProviderError.missingAppleCredential
        }

        let nonce = AppleSignInCoordinator.randomNonceString()
        let coordinator = AppleSignInCoordinator(anchor: anchor)
        let appleIDCredential = try await coordinator.performRequest(scopes: [.fullName, .email], nonce: nonce)

        guard let identityToken = appleIDCredential.identityToken,
              let idTokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthProviderError.missingAppleIdentityToken
        }

        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idTokenString,
            rawNonce: nonce
        )
        let firebaseUser = try await Auth.auth().signIn(with: credential).user

        let nickname = PersonNameComponentsFormatter().string(from: appleIDCredential.fullName ?? PersonNameComponents())
        return SocialSignInResult(
            // Apple의 안정적인 유저 식별자. 최초 로그인 시에만 fullName/email이 함께 온다.
            socialId: appleIDCredential.user,
            nickname: nickname.isEmpty ? firebaseUser.displayName : nickname,
            profileImageURL: firebaseUser.photoURL
        )
    }
}
