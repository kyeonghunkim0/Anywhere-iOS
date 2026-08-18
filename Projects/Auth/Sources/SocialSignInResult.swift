/// Firebase 로그인 결과와 함께 프로바이더가 발급한 idToken을 담는다.
/// 서버(`POST /api/auth/login`)는 Firebase를 모르고, 이 idToken을 각 프로바이더 공개키로
/// 직접 검증한 뒤 거기서 나온 sub만 socialId로 신뢰한다.
public struct SocialSignInResult: Sendable {
    /// google: GIDGoogleUser.idToken.tokenString / apple: ASAuthorizationAppleIDCredential.identityToken
    public let idToken: String
    public let nickname: String?

    public init(idToken: String, nickname: String?) {
        self.idToken = idToken
        self.nickname = nickname
    }
}
