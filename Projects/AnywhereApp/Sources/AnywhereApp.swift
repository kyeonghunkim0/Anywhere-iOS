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

    /// 개발 서버 주소. 실기기는 localhost로 붙을 수 없어 맥의 LAN IP로 바꿔야 한다.
    private let container = AppDependencyContainer(baseURL: URL(string: "http://172.20.10.2:3000")!)

    var body: some Scene {
        WindowGroup {
            LoginView(viewModel: LoginViewModel(signInUseCase: container.signInUseCase))
                .onOpenURL { url in
                    AppDependencyContainer.handleSocialAuthURL(url)
                }
        }
    }
}
