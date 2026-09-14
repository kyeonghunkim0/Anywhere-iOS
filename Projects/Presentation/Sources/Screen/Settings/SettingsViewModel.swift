//
//  SettingsViewModel.swift
//  Presentation
//
//  프로필 카드와 알림 스위치는 같은 응답(UserProfile)에서 나온다 —
//  설정을 바꾸면 서버가 갱신된 프로필을 그대로 돌려주므로 그걸 다시 담는다.
//

import Foundation
import Observation
import Domain
import UIComponents

@MainActor
@Observable
public final class SettingsViewModel {
    public private(set) var profile: UserProfile?
    public private(set) var isLoading = false
    /// 스위치를 누른 직후의 낙관적 표시값. 서버 응답이 오면 프로필 값으로 되돌아간다.
    public private(set) var isUpdatingPush = false
    public var errorMessage: String?

    private var hasLoaded = false

    /// 게스트 → 소셜 연결 중일 때만 true. 연결 버튼이 중복 탭되지 않게 한다.
    public private(set) var isLinkingAccount = false
    public private(set) var isDeletingAccount = false

    private let fetchMyProfileUseCase: FetchMyProfileUseCase
    private let updateSettingsUseCase: UpdateSettingsUseCase
    private let signOutUseCase: SignOutUseCase
    private let upgradeGuestAccountUseCase: UpgradeGuestAccountUseCase
    private let deleteAccountUseCase: DeleteAccountUseCase

    public init(
        fetchMyProfileUseCase: FetchMyProfileUseCase,
        updateSettingsUseCase: UpdateSettingsUseCase,
        signOutUseCase: SignOutUseCase,
        upgradeGuestAccountUseCase: UpgradeGuestAccountUseCase,
        deleteAccountUseCase: DeleteAccountUseCase
    ) {
        self.fetchMyProfileUseCase = fetchMyProfileUseCase
        self.updateSettingsUseCase = updateSettingsUseCase
        self.signOutUseCase = signOutUseCase
        self.upgradeGuestAccountUseCase = upgradeGuestAccountUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
    }

    public func load() async {
        guard !hasLoaded else { return }
        await reload()
    }

    public func reload() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do throws(AuthError) {
            profile = try await fetchMyProfileUseCase.execute()
            hasLoaded = true
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    public var pushEnabled: Bool { profile?.pushEnabled ?? false }

    public func setPushEnabled(_ isEnabled: Bool) async {
        guard !isUpdatingPush, isEnabled != pushEnabled else { return }
        isUpdatingPush = true
        defer { isUpdatingPush = false }

        do throws(ProfileError) {
            profile = try await updateSettingsUseCase.execute(pushEnabled: isEnabled)
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    /// 토큰과 소셜 세션을 지운다. 화면 전환은 호출부(RootViewModel)가 한다.
    public func signOut() async {
        await signOutUseCase.execute()
    }

    /// 탈퇴 성공 시 true를 돌려준다. 호출부는 이 값으로 로그아웃과 같은 화면 전환(onSignOut)을 트리거한다.
    @discardableResult
    public func deleteAccount() async -> Bool {
        guard !isDeletingAccount else { return false }
        isDeletingAccount = true
        defer { isDeletingAccount = false }

        do throws(AuthError) {
            try await deleteAccountUseCase.execute()
            return true
        } catch {
            errorMessage = Self.message(for: error)
            return false
        }
    }

    /// 게스트 계정에 소셜 로그인을 연결해 정회원으로 전환한다. 성공하면 프로필을 다시 읽어와
    /// `isGuest`가 반영된 최신 상태로 갱신한다.
    public func linkSocialAccount(socialType: SocialType) async {
        guard !isLinkingAccount else { return }
        isLinkingAccount = true
        defer { isLinkingAccount = false }

        do throws(AuthError) {
            _ = try await upgradeGuestAccountUseCase.execute(socialType: socialType)
            await reload()
        } catch .signInCancelled {
            // 사용자가 시스템 시트에서 직접 취소한 경우는 에러로 취급하지 않는다.
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    /// 번들에 박힌 이 빌드의 버전. 서버가 아는 최신 버전과는 별개다.
    public var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
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

    private static func message(for error: AuthError) -> String {
        switch error {
        case .rejected(let message):
            message
        case .sessionExpired:
            L10n.loginSessionExpired
        case .socialSignInFailed:
            L10n.loginSocialSignInFailed
        case .signInCancelled, .network:
            L10n.loginNetworkError
        }
    }
}
