//
//  RootViewModel.swift
//  Presentation
//
//  앱 진입 시 Keychain에 남아 있는 세션을 복구해 로그인/홈 전환을 결정한다.
//  위치 권한도 여기서 한 번 받는다 — 장소 검색의 거리 표시처럼 여러 화면이
//  현재 위치를 곁들여 쓰는데, 화면마다 물으면 다이얼로그가 흐름을 끊는다.
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

    /// 서버가 강제 업데이트를 요구하면 채워진다. nil이면 통과.
    /// state와 별개로, 값이 있으면 RootView가 로그인/홈 위에 차단 화면을 덮는다.
    public struct ForceUpdate: Equatable {
        public let message: String?
        public let storeURL: URL?
    }

    public private(set) var state: State = .restoring
    public private(set) var forceUpdate: ForceUpdate?

    /// storeUrl이 비어 올 때 쓰는 App Store 링크. 서버 .env(APP_STORE_URL)와 같은 값을 유지한다.
    private static let appStoreFallback = "https://apps.apple.com/us/app/%EC%96%B4%EB%94%94%EB%93%A0%EC%A7%80/id6795130564"

    private var hasAskedForLocation = false

    private let restoreSessionUseCase: RestoreSessionUseCase
    private let requestLocationPermissionUseCase: RequestLocationPermissionUseCase
    private let fetchAppInfoUseCase: FetchAppInfoUseCase

    public init(
        restoreSessionUseCase: RestoreSessionUseCase,
        requestLocationPermissionUseCase: RequestLocationPermissionUseCase,
        fetchAppInfoUseCase: FetchAppInfoUseCase
    ) {
        self.restoreSessionUseCase = restoreSessionUseCase
        self.requestLocationPermissionUseCase = requestLocationPermissionUseCase
        self.fetchAppInfoUseCase = fetchAppInfoUseCase
    }

    /// RootView의 .task에서 호출된다. View가 재구성돼도 복구를 두 번 돌리지 않는다.
    public func restoreIfNeeded() async {
        guard case .restoring = state else { return }

        // 세션 복구와 강제 업데이트 조회를 나란히 돌린다. 조회 실패는 통과(fail-open) —
        // 오프라인/서버 장애로 전 사용자가 잠기지 않게 한다.
        async let restored = restoreSessionUseCase.execute()
        async let appInfo = loadAppInfo()
        let (profile, info) = await (restored, appInfo)

        if let info, info.forceUpdate {
            forceUpdate = ForceUpdate(
                message: info.updateMessage,
                storeURL: URL(string: info.storeUrl ?? Self.appStoreFallback)
            )
        }

        if let profile {
            state = .authenticated(profile.user)
            askForLocationOnce()
        } else {
            state = .unauthenticated
        }
    }

    private func loadAppInfo() async -> AppInfo? {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return try? await fetchAppInfoUseCase.execute(version: version, platform: "ios")
    }

    public func authenticate(_ user: User) {
        state = .authenticated(user)
        askForLocationOnce()
    }

    /// 로그인 화면에서는 묻지 않는다 — 왜 필요한지 아직 못 본 사용자에게 물으면
    /// 거절당하기 쉽고, 한 번 거절되면 앱 안에서 되돌릴 수 없다.
    /// 이미 정해진 권한이면 UseCase가 다이얼로그 없이 그 상태를 그대로 돌려준다.
    private func askForLocationOnce() {
        guard !hasAskedForLocation else { return }
        hasAskedForLocation = true
        Task { _ = await requestLocationPermissionUseCase.execute() }
    }

    /// 로그아웃. 토큰을 지우는 건 UseCase가 하고, 화면 전환 권한은 여기 있다.
    public func signOut() {
        state = .unauthenticated
    }
}
