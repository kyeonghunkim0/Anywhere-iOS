//
//  RootView.swift
//  Presentation
//
//  저장된 세션 복구 결과에 따라 Splash/LoginView/HomeView를 전환하는 최상위 화면.
//  네비게이션 스택도 여기서 소유한다 — 화면마다 NavigationStack을 두면
//  push 목적지가 흩어져 코디네이터가 한 곳에서 제어할 수 없다.
//

import SwiftUI
import Domain

public struct RootView: View {
    @Bindable private var viewModel: RootViewModel
    @Bindable private var loginViewModel: LoginViewModel
    private let homeViewModelFactory: (User) -> HomeViewModel

    @State private var coordinator = NavigationCoordinator()

    public init(
        viewModel: RootViewModel,
        loginViewModel: LoginViewModel,
        homeViewModelFactory: @escaping (User) -> HomeViewModel
    ) {
        self.viewModel = viewModel
        self.loginViewModel = loginViewModel
        self.homeViewModelFactory = homeViewModelFactory
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content
                .navigationDestination(for: Route.self) { route in
                    RouteDestinationView(route: route)
                }
        }
        .environment(coordinator)
        .sheet(item: $coordinator.sheet) { route in
            RouteDestinationView(route: route)
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) { route in
            RouteDestinationView(route: route)
        }
    }

    @ViewBuilder
    private var content: some View {
        Group {
            switch viewModel.state {
            case .restoring:
                splash
            case .authenticated(let user):
                HomeView(
                    viewModel: homeViewModelFactory(user),
                    onStartTrip: { coordinator.pushViewController(.matching) },
                    onVerifyArrival: { coordinator.pushViewController(.arrivalVerification(matchId: $0)) },
                    onOpenProfile: { coordinator.pushViewController(.profile) },
                    onOpenPassport: { coordinator.pushViewController(.passport) },
                    onOpenRanking: { coordinator.pushViewController(.ranking) },
                    onOpenSettings: { coordinator.pushViewController(.settings) }
                )
            case .unauthenticated:
                LoginView(
                    viewModel: loginViewModel,
                    onTermsTap: { coordinator.present(.terms) },
                    onPrivacyTap: { coordinator.present(.privacy) }
                )
            }
        }
        // 세션이 바뀌면 이전 세션에서 쌓인 화면은 남기지 않는다.
        .onChange(of: authenticatedUserID) { _, _ in coordinator.reset() }
        .task { await viewModel.restoreIfNeeded() }
        // 로그인 성공은 LoginViewModel이 알고, 화면 전환 권한은 RootViewModel이 갖는다.
        .onChange(of: loginViewModel.session?.user.id) { _, _ in
            guard let user = loginViewModel.session?.user else { return }
            viewModel.authenticate(user)
        }
    }

    /// State가 Equatable이 아니라 세션 전환 감지는 사용자 식별자로 한다.
    private var authenticatedUserID: String? {
        if case .authenticated(let user) = viewModel.state { user.id } else { nil }
    }

    private var splash: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
    }
}
