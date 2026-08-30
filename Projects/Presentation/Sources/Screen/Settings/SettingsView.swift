//
//  SettingsView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isSettings 화면. 탭으로 열리므로 상단 바와
//  탭바는 MainTabView가 그린다.
//  프로토타입은 알림을 "스페셜 퀘스트 / 관심 로컬 레벨업" 둘로 나눠 두지만
//  서버 설정은 pushEnabled 하나뿐이라 한 줄로 합친다.
//

import SwiftUI
import Domain
import UIComponents

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    private let onOpenDocument: (LegalDocument) -> Void
    private let onSignOut: () -> Void

    init(
        viewModel: SettingsViewModel,
        onOpenDocument: @escaping (LegalDocument) -> Void = { _ in },
        onSignOut: @escaping () -> Void = {}
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onOpenDocument = onOpenDocument
        self.onSignOut = onSignOut
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.settingsTitle)
                    .font(DSTypography.font(32, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.textPrimary)
                    .padding(.horizontal, DSSpacing.s6)

                profileCard
                    .padding(.horizontal, DSSpacing.s6)
                    .padding(.top, 24)

                group(L10n.settingsGroupNotification) {
                    pushRow
                }

                group(L10n.settingsGroupInfo) {
                    documentRow(.terms, icon: .passport)
                    documentRow(.privacy, icon: .lock)
                    valueRow(icon: .compass, label: L10n.settingsAppVersion, value: viewModel.appVersion)
                }

                DSButton(L10n.settingsSignOut, variant: .secondary) {
                    Task {
                        await viewModel.signOut()
                        onSignOut()
                    }
                }
                .padding(.horizontal, DSSpacing.s6)
                .padding(.top, 34)
                .padding(.bottom, 36)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
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

    // MARK: - 프로필

    private var profileCard: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(DSColor.brandPrimary)
                .frame(width: 56, height: 56)
                .overlay {
                    Text(String((viewModel.profile?.user.nickname ?? "").prefix(1)))
                        .font(DSTypography.font(21, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(Color.white)
                }

            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.profile?.user.nickname ?? "")
                    .font(DSTypography.font(18, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)

                if let profile = viewModel.profile {
                    Text(subtitle(profile))
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)
                        .padding(.top, 5)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColor.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    /// "Lv.4 골목 개척자 · Google 연결". 레벨 문구는 서버가 만들어 준다.
    private func subtitle(_ profile: UserProfile) -> String {
        let connection = SocialType(rawValue: profile.user.socialType)?.label
        guard let connection else { return profile.levelLabel }
        return "\(profile.levelLabel) · \(L10n.settingsConnectedWith(connection))"
    }

    // MARK: - 그룹

    private func group<Content: View>(
        _ title: String,
        @ViewBuilder rows: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                .foregroundStyle(DSColor.textSecondary)
                .padding(.bottom, 4)

            rows()
        }
        .padding(.horizontal, DSSpacing.s6)
        .padding(.top, 30)
    }

    private var pushRow: some View {
        HStack(spacing: 12) {
            DSIconView(.sparkles, size: 17, color: DSColor.brandPrimary)

            Text(L10n.settingsPushNotification)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle(
                "",
                isOn: Binding(
                    get: { viewModel.pushEnabled },
                    set: { isOn in Task { await viewModel.setPushEnabled(isOn) } }
                )
            )
            .labelsHidden()
            .tint(DSColor.brandPrimary)
            .disabled(viewModel.profile == nil || viewModel.isUpdatingPush)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DSColor.border).frame(height: 1)
        }
    }

    private func documentRow(_ document: LegalDocument, icon: DSIcon) -> some View {
        Button { onOpenDocument(document) } label: {
            row(icon: icon, label: document.title, value: nil, showsChevron: true)
        }
        .buttonStyle(DSPressStyle())
    }

    private func valueRow(icon: DSIcon, label: String, value: String) -> some View {
        row(icon: icon, label: label, value: value, showsChevron: false)
    }

    private func row(icon: DSIcon, label: String, value: String?, showsChevron: Bool) -> some View {
        HStack(spacing: 12) {
            DSIconView(icon, size: 17, color: DSColor.brandPrimary)

            Text(label)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let value {
                Text(value)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textSecondary)
            }

            if showsChevron {
                DSIconView(.chevronRight, size: 13, color: DSColor.textMuted)
            }
        }
        .padding(.vertical, 17)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DSColor.border).frame(height: 1)
        }
    }
}

private extension SocialType {
    /// 브랜드 이름이라 번역하지 않는다.
    var label: String {
        switch self {
        case .google: "Google"
        case .apple: "Apple"
        }
    }
}
