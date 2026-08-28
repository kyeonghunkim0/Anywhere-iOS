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
    private let factory: ViewModelFactory

    @State private var coordinator = NavigationCoordinator()
    /// 조건 화면과 장소 검색 화면이 나눠 쓰는 선택 상태. 코디네이터와 같은 이유로 여기서 소유한다.
    @State private var tripPlan = TripPlanModel()

    public init(
        viewModel: RootViewModel,
        loginViewModel: LoginViewModel,
        factory: ViewModelFactory
    ) {
        self.viewModel = viewModel
        self.loginViewModel = loginViewModel
        self.factory = factory
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content
                .navigationDestination(for: Route.self) { route in
                    destination(route)
                }
        }
        .sheet(item: $coordinator.sheet) { route in
            destination(route)
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) { route in
            destination(route)
        }
        // sheet/fullScreenCover보다 바깥에 둬야 한다. 안쪽에 두면 띄워진 화면은
        // 이 모디파이어의 자손이 아니라서 코디네이터를 찾지 못하고 크래시한다.
        .environment(coordinator)
        .environment(tripPlan)
    }

    private func destination(_ route: Route) -> some View {
        RouteDestinationView(route: route, factory: factory)
    }

    @ViewBuilder
    private var content: some View {
        Group {
            switch viewModel.state {
            case .restoring:
                splash
            case .authenticated(let user):
                HomeScreen(viewModel: factory.home(user), coordinator: coordinator)
                    .id(user.id)
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

/// HomeViewModel을 @State로 소유한다. RootView body는 push/pop마다 다시 평가되는데,
/// 그때마다 새 ViewModel이 붙으면 진행 중이던 로드 결과가 버려진 인스턴스에 담겨
/// 화면이 빈 채로 남는다. 사용자가 바뀌면 .id(user.id)로 통째로 갈아끼운다.
private struct HomeScreen: View {
    @State private var viewModel: HomeViewModel
    private let coordinator: NavigationCoordinator

    @Environment(TripPlanModel.self) private var plan

    init(viewModel: HomeViewModel, coordinator: NavigationCoordinator) {
        _viewModel = State(wrappedValue: viewModel)
        self.coordinator = coordinator
    }

    var body: some View {
        HomeView(
            viewModel: viewModel,
            onStartTrip: {
                // 홈에서 새로 들어올 때마다 지난 선택은 지운다.
                plan.reset()
                coordinator.pushViewController(.tripFilter)
            },
            onVerifyArrival: { coordinator.pushViewController(.arrivalVerification(place: PlaceRef($0))) },
            onOpenProfile: { coordinator.pushViewController(.profile) },
            onOpenPassport: { coordinator.pushViewController(.passport) },
            onOpenRanking: { coordinator.pushViewController(.ranking) },
            onOpenSettings: { coordinator.pushViewController(.settings) }
        )
        // 루트로 돌아온 시점은 여정이 확정·취소됐을 수 있는 시점이다.
        // load()의 hasLoaded 가드 때문에 .task만으로는 갱신되지 않는다.
        .onChange(of: coordinator.path.isEmpty) { _, isRoot in
            guard isRoot else { return }
            Task { await viewModel.reload() }
        }
    }
}
