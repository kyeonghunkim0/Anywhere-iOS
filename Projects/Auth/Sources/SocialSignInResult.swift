import Foundation

/// Firebase 로그인 결과와 함께 프로바이더 원본 소셜 ID를 담는다.
/// 서버(`POST /api/auth/login`)는 Firebase를 모르고 이 원본 ID(socialId)만 신뢰한다.
public struct SocialSignInResult: Sendable {
    public let socialId: String
    public let nickname: String?
    public let profileImageURL: URL?

    public init(socialId: String, nickname: String?, profileImageURL: URL?) {
        self.socialId = socialId
        self.nickname = nickname
        self.profileImageURL = profileImageURL
    }
}
