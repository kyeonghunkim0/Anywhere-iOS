import Foundation

public enum SocialType: String, Sendable, Equatable {
    case google
    case apple
    case kakao
}

/// 소셜 SDK 로그인 결과. 서버에는 이 중 socialId만 전달된다.
public struct SocialCredential: Sendable {
    public let socialType: SocialType
    public let socialId: String
    public let nickname: String?
    public let profileImageURL: URL?

    public init(socialType: SocialType, socialId: String, nickname: String?, profileImageURL: URL?) {
        self.socialType = socialType
        self.socialId = socialId
        self.nickname = nickname
        self.profileImageURL = profileImageURL
    }
}
