//
//  BlockedUsersView.swift
//  Presentation
//

import SwiftUI
import Domain
import UIComponents

struct BlockedUsersView: View {
    @State private var viewModel: BlockedUsersViewModel
    private let onBack: () -> Void

    init(viewModel: BlockedUsersViewModel, onBack: @escaping () -> Void = {}) {
        _viewModel = State(wrappedValue: viewModel)
        self.onBack = onBack
    }

    var body: some View {
        VStack(spacing: 0) {
            BackBar(title: L10n.blockedUsersTitle, onBack: onBack)

            if viewModel.isLoading && viewModel.blockedUsers.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.blockedUsers.isEmpty {
                Text(L10n.blockedUsersEmpty)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                list
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .alert(
            L10n.homeErrorTitle,
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

    private var list: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(viewModel.blockedUsers) { user in
                    row(user)
                }
            }
            .padding(.horizontal, DSSpacing.s6)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
    }

    private func row(_ user: BlockedUser) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(DSColor.brandPrimary)
                .frame(width: 44, height: 44)
                .overlay {
                    Text(String(user.nickname.prefix(1)))
                        .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(Color.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(user.nickname)
                    .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.bold))
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)

                Text(user.blockedAt, format: .dateTime.year().month().day())
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.regular))
                    .foregroundStyle(DSColor.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(L10n.blockedUsersUnblock) {
                Task { await viewModel.unblock(userId: user.id) }
            }
            .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.bold))
            .foregroundStyle(DSColor.textSecondary)
            .disabled(viewModel.unblockingUserID != nil)
        }
        .padding(14)
        .background(DSColor.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
    }
}
