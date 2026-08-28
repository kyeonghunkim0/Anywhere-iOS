//
//  ArrivalVerificationView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isGpsSuccess 화면.
//  프로토타입은 홈에서 이미 체크인이 끝난 뒤 이 화면으로 넘어오지만,
//  실제로는 여기 들어온 시점에 체크인을 한 번 시도한다 — 성공/실패를 판정하는
//  주체가 서버 하나여야 홈이 "500m 이탈" 같은 사유를 흉내내지 않아도 된다.
//

import SwiftUI
import Domain
import UIComponents

struct ArrivalVerificationView: View {
    /// ViewModel은 이 뷰가 소유한다. 부모(RouteDestinationView) body가 다시 평가될 때마다
    /// 팩토리가 새 인스턴스를 만드는데, 참조만 들고 있으면 진행 중이던 상태가 통째로 버려진다
    /// — 화면은 로딩에서 멈추고 .task는 identity가 같아 다시 돌지도 않는다.
    @State private var viewModel: ArrivalVerificationViewModel
    private let onBack: () -> Void
    private let onWriteReview: () -> Void
    private let onDone: () -> Void

    /// 도장 둘레에서 번지는 잉크 링. 애니메이션 시작 전후로 값만 바뀐다.
    @State private var ringExpanded = false

    init(
        viewModel: ArrivalVerificationViewModel,
        onBack: @escaping () -> Void = {},
        onWriteReview: @escaping () -> Void = {},
        onDone: @escaping () -> Void = {}
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onBack = onBack
        self.onWriteReview = onWriteReview
        self.onDone = onDone
    }

    var body: some View {
        Group {
            if let result = viewModel.result {
                success(result)
            } else {
                loading
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.checkIn() }
        .alert(
            L10n.arrivalFailureTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(L10n.arrivalRetry) { Task { await viewModel.checkIn() } }
            Button(L10n.commonBack, role: .cancel) { onBack() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    /// 확인이 길어질 때 빠져나갈 구멍을 남긴다 — 이 화면은 네비게이션 바를 숨기고 있어
    /// 뒤로가기 줄이 없으면 응답이 올 때까지 사용자가 갇힌다.
    private var loading: some View {
        VStack(spacing: 0) {
            BackBar(onBack: onBack)

            VStack(spacing: 16) {
                ProgressView()
                Text(L10n.arrivalCheckingIn)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func success(_ result: CheckInResult) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                stampMark
                headline(visitorNumber: result.stamp.visitorNumber)
                rewards
                actions
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var stampMark: some View {
        ZStack {
            Circle()
                .strokeBorder(DSColor.brandPrimary, lineWidth: 2)
                .frame(width: 112, height: 112)
                .scaleEffect(ringExpanded ? 1.35 : 0.7)
                .opacity(ringExpanded ? 0 : 0.45)

            Circle()
                .fill(DSColor.green50)
                .frame(width: 88, height: 88)
                .overlay {
                    Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 2)
                }
                .overlay {
                    DSIconView(.pin, size: 34, color: DSColor.brandPrimary)
                }
        }
        .frame(width: 112, height: 112)
        .padding(.top, 64)
        .onAppear {
            withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: false)) {
                ringExpanded = true
            }
        }
    }

    private func headline(visitorNumber: Int) -> some View {
        VStack(spacing: 0) {
            Text(viewModel.placeName)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                .foregroundStyle(DSColor.textSecondary)
                .padding(.top, 14)

            Text(L10n.arrivalStamped)
                .font(DSTypography.font(32, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.top, 18)

            Text(visitorLine(visitorNumber))
                .font(DSTypography.font(DSTypography.Size.md, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.sand800)
                .lineSpacing(DSTypography.lineSpacing(size: DSTypography.Size.md, leading: 1.55))
                .padding(.top, 14)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, DSSpacing.s6)
    }

    /// 방문 순번만 도장 잉크색으로 강조한다 — 프로토타입과 같은 처리.
    private func visitorLine(_ number: Int) -> AttributedString {
        var prefix = AttributedString(L10n.arrivalVisitorPrefix)
        prefix.foregroundColor = DSColor.sand800

        var highlight = AttributedString(L10n.arrivalVisitorNumber(number))
        highlight.foregroundColor = DSColor.brandAccent
        highlight.font = DSTypography.font(DSTypography.Size.md, weight: DSTypography.Weight.extrabold)

        var suffix = AttributedString(L10n.arrivalVisitorSuffix)
        suffix.foregroundColor = DSColor.sand800

        return prefix + highlight + suffix
    }

    private var rewards: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.rewards) { reward in
                HStack(spacing: 12) {
                    DSIconView(reward.icon, size: 16, color: DSColor.brandPrimary)
                    Text(reward.label)
                        .font(DSTypography.font(14, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.ink900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(DSColor.sand50)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            }
        }
        .padding(.horizontal, DSSpacing.s6)
        .padding(.top, 28)
    }

    private var actions: some View {
        VStack(spacing: 10) {
            DSButton(L10n.arrivalWriteReview, variant: .primary, action: onWriteReview)
            // 프로토타입의 "여권에서 보기" 자리. 여권 화면이 생기기 전까지는 홈으로 보낸다.
            DSButton(L10n.arrivalGoHome, variant: .secondary, action: onDone)
        }
        .padding(.horizontal, DSSpacing.s6)
        .padding(.top, 28)
        .padding(.bottom, 32)
    }
}
