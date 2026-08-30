//
//  ProfileEditView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isProfileEdit 화면.
//  프로토타입의 "사진 변경"과 "여권 번호"는 각각 업로드 API와 서버 계약이 없어 옮기지 않는다.
//

import SwiftUI
import Domain
import UIComponents

struct ProfileEditView: View {
    @State private var viewModel: ProfileEditViewModel
    private let onSaved: () -> Void
    private let onBack: () -> Void

    @FocusState private var isFieldFocused: Bool

    init(
        viewModel: ProfileEditViewModel,
        onSaved: @escaping () -> Void = {},
        onBack: @escaping () -> Void = {}
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onSaved = onSaved
        self.onBack = onBack
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            avatar
                .padding(.top, 36)
                .padding(.bottom, 28)

            nicknameField
                .padding(.horizontal, DSSpacing.s6)

            Spacer(minLength: 0)
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { isFieldFocused = true }
        .alert(
            L10n.profileEditFailureTitle,
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

    private var topBar: some View {
        HStack(spacing: 4) {
            Button(action: onBack) {
                DSIconView(.chevronRight, size: 19, color: DSColor.ink900)
                    .rotationEffect(.degrees(180))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(DSPressStyle())
            .accessibilityLabel(L10n.commonBack)

            Text(L10n.profileEditTitle)
                .font(DSTypography.font(DSTypography.Size.md, weight: DSTypography.Weight.bold))
                .foregroundStyle(DSColor.ink900)
                .frame(maxWidth: .infinity)

            Button {
                Task { if await viewModel.save() != nil { onSaved() } }
            } label: {
                Text(L10n.profileEditSave)
                    .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.bold))
                    .foregroundStyle(viewModel.canSave ? DSColor.brandPrimary : DSColor.textMuted)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
            }
            .buttonStyle(DSPressStyle())
            .disabled(!viewModel.canSave)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DSColor.border).frame(height: 1)
        }
    }

    private var avatar: some View {
        Circle()
            .fill(DSColor.brandPrimary)
            .frame(width: 104, height: 104)
            .overlay {
                Text(String(viewModel.trimmedNickname.prefix(1)))
                    .font(DSTypography.font(38, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(Color.white)
            }
    }

    private var nicknameField: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.profileEditNickname)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                .foregroundStyle(DSColor.textSecondary)
                .padding(.bottom, 10)

            HStack(spacing: 10) {
                TextField("", text: $viewModel.nickname)
                    .font(DSTypography.font(16, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textPrimary)
                    .focused($isFieldFocused)
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.nickname) { _, _ in viewModel.clampNickname() }

                Text(viewModel.countLabel)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textMuted)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DSColor.border, lineWidth: 1)
            }

            Text(L10n.profileEditNicknameHint(ProfileEditViewModel.nicknameLimit))
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
                .foregroundStyle(DSColor.textSecondary)
                .padding(.top, 10)
        }
    }
}
