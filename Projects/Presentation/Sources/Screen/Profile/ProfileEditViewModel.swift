//
//  ProfileEditViewModel.swift
//  Presentation
//
//  닉네임만 고친다. 서버 updateProfile은 프로필 사진도 받지만 이미지를 올릴
//  엔드포인트가 없어 이 화면에서는 다루지 않는다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class ProfileEditViewModel {
    public var nickname: String
    public private(set) var isSaving = false
    public var errorMessage: String?

    /// 서버가 12자로 자른다 — 화면도 같은 한도를 쓴다.
    public static let nicknameLimit = 12

    private let originalNickname: String
    private let updateProfileUseCase: UpdateProfileUseCase

    public init(nickname: String, updateProfileUseCase: UpdateProfileUseCase) {
        self.nickname = nickname
        self.originalNickname = nickname
        self.updateProfileUseCase = updateProfileUseCase
    }

    public var trimmedNickname: String {
        nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var canSave: Bool {
        !isSaving && !trimmedNickname.isEmpty && trimmedNickname != originalNickname
    }

    public var countLabel: String { "\(nickname.count)/\(Self.nicknameLimit)" }

    /// 한도를 넘겨 입력되면 잘라낸다.
    public func clampNickname() {
        if nickname.count > Self.nicknameLimit {
            nickname = String(nickname.prefix(Self.nicknameLimit))
        }
    }

    /// 저장 성공 시 갱신된 프로필. 실패하면 nil.
    public func save() async -> UserProfile? {
        guard canSave else { return nil }
        isSaving = true
        defer { isSaving = false }

        do throws(ProfileError) {
            return try await updateProfileUseCase.execute(nickname: trimmedNickname, profileImage: nil)
        } catch {
            errorMessage = Self.message(for: error)
            return nil
        }
    }

    private static func message(for error: ProfileError) -> String {
        switch error {
        case .rejected(let message):
            message
        case .sessionExpired:
            L10n.loginSessionExpired
        case .network:
            L10n.loginNetworkError
        }
    }
}
