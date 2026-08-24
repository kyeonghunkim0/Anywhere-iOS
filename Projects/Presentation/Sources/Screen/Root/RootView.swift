//
//  RootView.swift
//  Presentation
//
//  저장된 세션 복구 결과에 따라 Splash/LoginView/HomeView를 전환하는 최상위 화면.
//

import SwiftUI
import Domain

public struct RootView: View {
    @Bindable private var viewModel: RootViewModel
    @Bindable private var loginViewModel: LoginViewModel
    private let homeViewModelFactory: (User) -> HomeViewModel

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
        Group {
            switch viewModel.state {
            case .restoring:
                splash
            case .authenticated(let user):
                HomeView(viewModel: homeViewModelFactory(user))
            case .unauthenticated:
                LoginView(viewModel: loginViewModel)
            }
        }
        .task { await viewModel.restoreIfNeeded() }
        // 로그인 성공은 LoginViewModel이 알고, 화면 전환 권한은 RootViewModel이 갖는다.
        .onChange(of: loginViewModel.session?.user.id) { _, _ in
            guard let user = loginViewModel.session?.user else { return }
            viewModel.authenticate(user)
        }
    }

    private var splash: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
    }
}
