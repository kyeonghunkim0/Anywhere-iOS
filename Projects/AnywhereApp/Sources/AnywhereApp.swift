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
        #if DEBUG
        /// 개발 서버 주소. 실기기는 localhost로 붙을 수 없어 맥의 LAN IP로 바꿔야 한다.
        let baseURL = URL(string: "http://192.168.219.106:3000")!
        #else
        /// 운영 서버 주소.
        let baseURL = URL(string: "http://161.33.223.198")!
        #endif
        let container = AppDependencyContainer(baseURL: baseURL)
        self.container = container
        _rootViewModel = State(wrappedValue: RootViewModel(restoreSessionUseCase: container.restoreSessionUseCase))
        _loginViewModel = State(wrappedValue: LoginViewModel(signInUseCase: container.signInUseCase))
    }

    var body: some Scene {
        WindowGroup {
            // ⚠️ 임시. DEBUG_SCREEN 환경변수가 있으면 그 화면만 가짜 응답으로 띄운다.
            // 서버·로그인 없이 화면을 눈으로 보기 위한 우회로다 — 확인이 끝나면 지운다.
            #if DEBUG
            if let debugScreen = DebugScreenView(rawValue: ProcessInfo.processInfo.environment["DEBUG_SCREEN"]) {
                debugScreen
            } else {
                rootView
            }
            #else
            rootView
            #endif
        }
    }

    private var rootView: some View {
        RootView(
            viewModel: rootViewModel,
            loginViewModel: loginViewModel,
            factory: ViewModelFactory(
                home: { user in
                    HomeViewModel(
                        user: user,
                        fetchCurrentTripUseCase: container.fetchCurrentTripUseCase,
                        fetchSeasonalBadgesUseCase: container.fetchSeasonalBadgesUseCase,
                        fetchGrowthRegionsUseCase: container.fetchGrowthRegionsUseCase,
                        cancelMatchUseCase: container.cancelMatchUseCase,
                        requestLocationPermissionUseCase: container.requestLocationPermissionUseCase
                    )
                },
                matching: { radiusKm in
                    MatchingViewModel(
                        radiusKm: radiusKm,
                        fetchRandomMatchUseCase: container.fetchRandomMatchUseCase
                    )
                },
                matchResult: { match, radiusKm in
                    MatchResultViewModel(
                        match: match,
                        radiusKm: radiusKm,
                        fetchRandomMatchUseCase: container.fetchRandomMatchUseCase,
                        confirmMatchUseCase: container.confirmMatchUseCase
                    )
                },
                placeSearch: {
                    PlaceSearchViewModel(
                        fetchSearchablePlacesUseCase: container.fetchSearchablePlacesUseCase
                    )
                },
                passport: { userId in
                    PassportViewModel(
                        userId: userId,
                        fetchPassportUseCase: container.fetchPassportUseCase,
                        fetchMyBadgesUseCase: container.fetchMyBadgesUseCase
                    )
                },
                ranking: {
                    RankingViewModel(
                        fetchGrowthRegionsUseCase: container.fetchGrowthRegionsUseCase,
                        fetchUserRankingUseCase: container.fetchUserRankingUseCase,
                        fetchMyRankUseCase: container.fetchMyRankUseCase
                    )
                },
                arrivalVerification: { place in
                    ArrivalVerificationViewModel(
                        place: place,
                        checkInUseCase: container.checkInUseCase
                    )
                },
                review: { place in
                    ReviewViewModel(
                        place: place,
                        createReviewUseCase: container.createReviewUseCase
                    )
                }
            )
        )
        .onOpenURL { url in
            AppDependencyContainer.handleSocialAuthURL(url)
        }
    }
}
