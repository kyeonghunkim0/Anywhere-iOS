//
//  AnywhereApp.swift
//  AnywhereApp
//
//  Created by 김경훈 on 7/27/26.
//  Copyright © 2026 com.kimkhuna. All rights reserved.
//

import SwiftUI
import DIContainer
import Presentation

final class AnywhereAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppDependencyContainer.configureSocialAuth()
        return true
    }
}

@main
struct AnywhereApp: App {
    @UIApplicationDelegateAdaptor(AnywhereAppDelegate.self) private var appDelegate

    private let container: AppDependencyContainer
    // body가 다시 평가돼도 세션 복구 상태가 초기화되지 않도록 @State로 소유한다.
    @State private var rootViewModel: RootViewModel
    @State private var loginViewModel: LoginViewModel

    init() {
        /// 개발 서버 주소. 실기기는 localhost로 붙을 수 없어 맥의 LAN IP로 바꿔야 한다.
        let container = AppDependencyContainer(baseURL: URL(string: "http://172.20.10.3:3000")!)
        self.container = container
        _rootViewModel = State(wrappedValue: RootViewModel(restoreSessionUseCase: container.restoreSessionUseCase))
        _loginViewModel = State(wrappedValue: LoginViewModel(signInUseCase: container.signInUseCase))
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                viewModel: rootViewModel,
                loginViewModel: loginViewModel,
                homeViewModelFactory: { user in
                    HomeViewModel(
                        user: user,
                        fetchCurrentTripUseCase: container.fetchCurrentTripUseCase,
                        fetchSeasonalBadgesUseCase: container.fetchSeasonalBadgesUseCase,
                        fetchGrowthRegionsUseCase: container.fetchGrowthRegionsUseCase,
                        cancelMatchUseCase: container.cancelMatchUseCase,
                        requestLocationPermissionUseCase: container.requestLocationPermissionUseCase
                    )
                },
                matchingViewModelFactory: { radiusKm in
                    MatchingViewModel(
                        radiusKm: radiusKm,
                        fetchRandomMatchUseCase: container.fetchRandomMatchUseCase
                    )
                }
            )
            .onOpenURL { url in
                AppDependencyContainer.handleSocialAuthURL(url)
            }
        }
    }
}
