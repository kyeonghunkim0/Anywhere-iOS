//
//  MainTabView.swift
//  Presentation
//
//  로그인 후의 뼈대. 프로토타입의 showNav = [home, passport, ranking, settings]가
//  그대로 탭이 된다 — 이 네 화면은 밀고 들어가는 게 아니라 서로 갈아끼워지므로
//  상단 바와 하단 탭바는 화면이 아니라 이 컨테이너가 소유한다.
//

import SwiftUI
import Domain
import UIComponents

struct MainTabView: View {
    enum Tab: String, CaseIterable {
        case home, passport, ranking, settings
    }

    @State private var homeViewModel: HomeViewModel
    @State private var passportViewModel: PassportViewModel
    @State private var rankingViewModel: RankingViewModel
    @State private var tab: Tab = .home

    @Environment(NavigationCoordinator.self) private var coordinator

    private let userID: String
    private let nicknameInitial: String
    private let onStartTrip: () -> Void
    private let onVerifyArrival: (Place) -> Void
    private let onOpenProfile: () -> Void

    init(
        homeViewModel: HomeViewModel,
        passportViewModel: PassportViewModel,
        rankingViewModel: RankingViewModel,
        userID: String,
        nicknameInitial: String,
        onStartTrip: @escaping () -> Void = {},
        onVerifyArrival: @escaping (Place) -> Void = { _ in },
        onOpenProfile: @escaping () -> Void = {}
    ) {
        _homeViewModel = State(wrappedValue: homeViewModel)
        _passportViewModel = State(wrappedValue: passportViewModel)
        _rankingViewModel = State(wrappedValue: rankingViewModel)
        self.userID = userID
        self.nicknameInitial = nicknameInitial
        self.onStartTrip = onStartTrip
        self.onVerifyArrival = onVerifyArrival
        self.onOpenProfile = onOpenProfile
    }

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .top, spacing: 0) { topBar }

            DSBottomNav(items: navItems, selection: selectionBinding)
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(edges: .bottom)
        // 루트로 돌아온 시점은 여정이 확정·취소됐을 수 있는 시점이다.
        // load()의 hasLoaded 가드 때문에 .task만으로는 갱신되지 않는다.
        .onChange(of: coordinator.path.isEmpty) { _, isRoot in
            guard isRoot else { return }
            Task { await homeViewModel.reload() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .home:
            HomeView(
                viewModel: homeViewModel,
                onStartTrip: onStartTrip,
                onVerifyArrival: onVerifyArrival
            )
        case .passport:
            PassportView(viewModel: passportViewModel) { section in
                coordinator.pushViewController(.passportDetail(userId: userID, section: section))
            }
        case .ranking:
            RankingView(viewModel: rankingViewModel)
        case .settings:
            comingSoon
        }
    }

    /// DSBottomNav는 문자열 id로 고른다 — 탭 열거형과의 변환만 여기서 흡수한다.
    private var selectionBinding: Binding<String> {
        Binding(
            get: { tab.rawValue },
            set: { tab = Tab(rawValue: $0) ?? .home }
        )
    }

    private var navItems: [DSBottomNavItem] {
        [
            .init(id: Tab.home.rawValue, icon: .home, label: L10n.homeNavHome),
            .init(id: Tab.passport.rawValue, icon: .passport, label: L10n.homeNavPassport),
            .init(id: Tab.ranking.rawValue, icon: .flame, label: L10n.homeNavRanking),
            .init(id: Tab.settings.rawValue, icon: .settings, label: L10n.homeNavSettings),
        ]
    }

    /// NavigationStack의 기본 툴바 대신 쓴다 — iOS 26 툴바가 Button이 아닌 항목을
    /// "···" 캡슐로 접어버려서, 로고를 원하는 위치에 못 그린다. safeAreaInset은
    /// 세이프에어리어 계산은 시스템에 맡기면서 레이아웃은 그대로 직접 그릴 수 있다.
    private var topBar: some View {
        HStack {
            Spacer()

            Button(action: onOpenProfile) {
                Circle()
                    .fill(DSColor.green50)
                    .frame(width: 38, height: 38)
                    .overlay {
                        Text(nicknameInitial)
                            .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                            .foregroundStyle(DSColor.brandPrimary)
                    }
            }
            .buttonStyle(DSPressStyle())
        }
        .padding(.horizontal, DSSpacing.s6)
        .padding(.top, DSSpacing.s3)
        .padding(.bottom, DSSpacing.s2)
        .background(Color.white)
    }

    private var comingSoon: some View {
        VStack(spacing: DSSpacing.s2) {
            Text(L10n.commonComingSoon)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
