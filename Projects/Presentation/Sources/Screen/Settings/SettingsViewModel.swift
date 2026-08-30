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

    private let fetchMyProfileUseCase: FetchMyProfileUseCase
    private let updateSettingsUseCase: UpdateSettingsUseCase
    private let signOutUseCase: SignOutUseCase

    public init(
        fetchMyProfileUseCase: FetchMyProfileUseCase,
        updateSettingsUseCase: UpdateSettingsUseCase,
        signOutUseCase: SignOutUseCase
    ) {
        self.fetchMyProfileUseCase = fetchMyProfileUseCase
        self.updateSettingsUseCase = updateSettingsUseCase
        self.signOutUseCase = signOutUseCase
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
        case .signInCancelled, .network:
            L10n.loginNetworkError
        }
    }
}
