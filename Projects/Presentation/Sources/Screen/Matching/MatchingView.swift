//
//  MatchingView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isMatching 화면. 프로토타입의 GIF는 Lottie로 대체한다.
//  프로토타입의 "전국 3,412곳 중에서" 같은 수치는 서버가 주지 않는 값이라 옮기지 않는다.
//

import SwiftUI
import Lottie
import Domain
import UIComponents

struct MatchingView: View {
    /// ViewModel은 이 뷰가 소유한다. 부모(RouteDestinationView) body가 다시 평가될 때마다
    /// 팩토리가 새 인스턴스를 만드는데, 참조만 들고 있으면 진행 중이던 상태가 통째로 버려진다
    /// — 화면은 로딩에서 멈추고 .task는 identity가 같아 다시 돌지도 않는다.
    @State private var viewModel: MatchingViewModel
    private let onBack: () -> Void
    private let onMatched: (RandomMatch) -> Void

    /// 값이 바뀌면 Lottie가 애니메이션을 처음부터 다시 재생한다 — 재시도에 쓴다.
    @State private var replayToken = 0

    init(
        viewModel: MatchingViewModel,
        onBack: @escaping () -> Void = {},
        onMatched: @escaping (RandomMatch) -> Void = { _ in }
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onBack = onBack
        self.onMatched = onMatched
    }

    var body: some View {
        VStack(spacing: 0) {
            BackBar(onBack: onBack)

            LottieView(animation: .named("dart-throw-map", bundle: Bundle.module))
                .resizable()
                .playing(loopMode: .playOnce)
                .animationDidFinish { _ in
                    viewModel.animationDidFinish()
                }
                .reloadAnimationTrigger(replayToken)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DSColor.sand100)
                .clipped()

            caption
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .onChange(of: viewModel.matchedResult?.matchId) { _, matchId in
            guard matchId != nil, let match = viewModel.matchedResult else { return }
            onMatched(match)
        }
        .alert(
            L10n.matchingFailureTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in if !isPresented { onBack() } }
            )
        ) {
            Button(L10n.matchingRetry) { retry() }
            Button(L10n.commonBack, role: .cancel) { onBack() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var caption: some View {
        VStack(spacing: 12) {
            Text(L10n.matchingTitle)
                .font(DSTypography.font(26, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)

            Text(L10n.matchingSubtitle)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
                .foregroundStyle(DSColor.textSecondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DSSpacing.s6)
        .padding(.top, 32)
        .padding(.bottom, 44)
        .background(Color.white)
    }

    private func retry() {
        viewModel.prepareForRetry()
        replayToken += 1
        Task { await viewModel.load() }
    }
}
