//
//  ReviewView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isReview 화면.
//

import SwiftUI
import UIComponents

struct ReviewView: View {
    /// ViewModel은 이 뷰가 소유한다. 부모(RouteDestinationView) body가 다시 평가될 때마다
    /// 팩토리가 새 인스턴스를 만드는데, 참조만 들고 있으면 진행 중이던 상태가 통째로 버려진다
    /// — 화면은 로딩에서 멈추고 .task는 identity가 같아 다시 돌지도 않는다.
    @State private var viewModel: ReviewViewModel
    private let onBack: () -> Void
    private let onSubmitted: () -> Void

    @FocusState private var isEditorFocused: Bool

    init(
        viewModel: ReviewViewModel,
        onBack: @escaping () -> Void = {},
        onSubmitted: @escaping () -> Void = {}
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onBack = onBack
        self.onSubmitted = onSubmitted
    }

    var body: some View {
        VStack(spacing: 0) {
            BackBar(title: L10n.reviewTitleFormat(viewModel.placeName), onBack: onBack)

            editor
                .padding(.horizontal, DSSpacing.s6)
                .padding(.top, 20)

            Spacer(minLength: 0)
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            DSButton(L10n.reviewSubmit, variant: .primary) {
                Task { if await viewModel.submit() { onSubmitted() } }
            }
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.canSubmit ? 1 : 0.5)
            .padding(.horizontal, DSSpacing.s6)
            .padding(.top, 16)
            .padding(.bottom, 32)
            .background(Color.white)
        }
        .onAppear { isEditorFocused = true }
        .alert(
            L10n.reviewFailureTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(L10n.commonConfirm, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var editor: some View {
        VStack(alignment: .trailing, spacing: 8) {
            TextEditor(text: $viewModel.text)
                .focused($isEditorFocused)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.regular))
                .foregroundStyle(DSColor.ink900)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(height: 120)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.xl, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: DSRadius.xl, style: .continuous)
                        .strokeBorder(DSColor.border, lineWidth: 1)
                }
                // TextEditor에는 placeholder가 없어 비었을 때만 글자를 겹쳐 둔다.
                .overlay(alignment: .topLeading) {
                    if viewModel.text.isEmpty {
                        Text(L10n.reviewPlaceholder)
                            .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.regular))
                            .foregroundStyle(DSColor.textMuted)
                            // TextEditor 내부 여백(가로 5 · 세로 8)을 더해 입력 글자와 정확히 겹치게 둔다.
                            .padding(.horizontal, 19)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }

            Text(viewModel.counter)
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textSecondary)
        }
    }
}
