//
//  ReportReviewView.swift
//  Presentation
//
//  시트로 뜬다. 사유 4개 중 하나를 고르고(ETC는 상세 사유 필수) 제출한다.
//

import SwiftUI
import Domain
import UIComponents

struct ReportReviewView: View {
    @State private var viewModel: ReportReviewViewModel
    private let onClose: () -> Void

    init(viewModel: ReportReviewViewModel, onClose: @escaping () -> Void = {}) {
        _viewModel = State(wrappedValue: viewModel)
        self.onClose = onClose
    }

    var body: some View {
        VStack(spacing: 0) {
            BackBar(title: L10n.reviewReportTitle, onBack: onClose)

            if viewModel.isSubmitted {
                submitted
            } else {
                form
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            L10n.reviewReportFailureTitle,
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

    private var form: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 8) {
                ForEach(ReportReason.allCases, id: \.self) { reason in
                    reasonRow(reason)
                }
            }
            .padding(.top, 12)

            if viewModel.selectedReason == .etc {
                TextField(L10n.reviewReportDetailPlaceholder, text: $viewModel.detail, axis: .vertical)
                    .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.regular))
                    .padding(12)
                    .background(DSColor.surfaceSunken)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
                    .padding(.top, 16)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, DSSpacing.s6)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            DSButton(L10n.reviewReportSubmit, variant: .primary) {
                Task { await viewModel.submit() }
            }
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.canSubmit ? 1 : 0.5)
            .padding(.horizontal, DSSpacing.s6)
            .padding(.top, 16)
            .padding(.bottom, 32)
            .background(Color.white)
        }
    }

    private func reasonRow(_ reason: ReportReason) -> some View {
        Button {
            viewModel.selectedReason = reason
        } label: {
            HStack {
                Text(title(for: reason))
                    .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textPrimary)

                Spacer()

                if viewModel.selectedReason == reason {
                    DSIconView(.check, size: 16, color: DSColor.brandPrimary)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(viewModel.selectedReason == reason ? DSColor.green50 : DSColor.surfaceSunken)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                    .strokeBorder(viewModel.selectedReason == reason ? DSColor.brandPrimary : .clear, lineWidth: 1)
            }
        }
        .buttonStyle(DSPressStyle())
    }

    private func title(for reason: ReportReason) -> String {
        switch reason {
        case .spam: L10n.reviewReportReasonSpam
        case .abuse: L10n.reviewReportReasonAbuse
        case .inappropriate: L10n.reviewReportReasonInappropriate
        case .etc: L10n.reviewReportReasonEtc
        }
    }

    private var submitted: some View {
        VStack(spacing: 12) {
            Spacer()

            Text(L10n.reviewReportSuccessMessage)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textPrimary)
                .multilineTextAlignment(.center)

            Spacer()

            DSButton(L10n.commonConfirm, variant: .primary) { onClose() }
                .padding(.horizontal, DSSpacing.s6)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
    }
}
