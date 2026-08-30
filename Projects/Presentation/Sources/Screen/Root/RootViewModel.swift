//
//  RootViewModel.swift
//  Presentation
//
//  앱 진입 시 Keychain에 남아 있는 세션을 복구해 로그인/홈 전환을 결정한다.
//

import Foundation
import Domain

@MainActor
@Observable
public final class RootViewModel {
    public enum State {
        /// 복구 시도 중 — 로그인 화면이 한 프레임 깜빡이지 않도록 첫 상태로 둔다.
        case restoring
        case authenticated(User)
        case unauthenticated
    }

    public private(set) var state: State = .restoring

    private let restoreSessionUseCase: RestoreSessionUseCase

    public init(restoreSessionUseCase: RestoreSessionUseCase) {
        self.restoreSessionUseCase = restoreSessionUseCase
    }

    /// RootView의 .task에서 호출된다. View가 재구성돼도 복구를 두 번 돌리지 않는다.
    public func restoreIfNeeded() async {
        guard case .restoring = state else { return }
        if let profile = await restoreSessionUseCase.execute() {
            state = .authenticated(profile.user)
        } else {
            state = .unauthenticated
        }
    }

    public func authenticate(_ user: User) {
        state = .authenticated(user)
    }

    /// 로그아웃. 토큰을 지우는 건 UseCase가 하고, 화면 전환 권한은 여기 있다.
    public func signOut() {
        state = .unauthenticated
    }
}
