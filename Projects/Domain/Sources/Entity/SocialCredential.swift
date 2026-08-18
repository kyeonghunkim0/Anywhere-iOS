public enum SocialType: String, Sendable, Equatable {
    case google
    case apple
}

/// 소셜 SDK 로그인 결과. 서버는 idToken을 각 프로바이더 공개키로 직접 검증하고,
/// 거기서 나온 sub만 socialId로 신뢰한다 — 클라이언트가 socialId를 보내지 않는다.
public struct SocialCredential: Sendable {
    public let socialType: SocialType
    /// google: GIDGoogleUser.idToken.tokenString / apple: ASAuthorizationAppleIDCredential.identityToken
    public let idToken: String
    public let nickname: String?

    public init(socialType: SocialType, idToken: String, nickname: String?) {
        self.socialType = socialType
        self.idToken = idToken
        self.nickname = nickname
    }
}
