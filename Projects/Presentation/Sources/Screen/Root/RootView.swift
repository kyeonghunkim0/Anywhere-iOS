//
//  RootView.swift
//  Presentation
//
//  로그인 여부에 따라 LoginView/HomeView를 전환하는 최상위 화면.
//

import SwiftUI
import Domain

public struct RootView: View {
    @Bindable private var loginViewModel: LoginViewModel
    private let homeViewModelFactory: (AuthSession) -> HomeViewModel

    public init(
        loginViewModel: LoginViewModel,
        homeViewModelFactory: @escaping (AuthSession) -> HomeViewModel
    ) {
        self.loginViewModel = loginViewModel
        self.homeViewModelFactory = homeViewModelFactory
    }

    public var body: some View {
        if let session = loginViewModel.session {
            HomeView(viewModel: homeViewModelFactory(session))
        } else {
            LoginView(viewModel: loginViewModel)
        }
    }
}
