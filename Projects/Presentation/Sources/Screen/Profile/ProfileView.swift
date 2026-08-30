//
//  ProfileView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isProfile 화면.
//  프로토타입의 "서울–부산 3.4회" 같은 환산 문구와 기록 행의 셰브론은
//  서버 값도 이동할 화면도 없어 옮기지 않는다.
//

import SwiftUI
import Domain
import UIComponents

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    private let onEdit: (String) -> Void
    private let onBack: () -> Void

    @Environment(NavigationCoordinator.self) private var coordinator

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    init(
        viewModel: ProfileViewModel,
        onEdit: @escaping (String) -> Void = { _ in },
        onBack: @escaping () -> Void = {}
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onEdit = onEdit
        self.onBack = onBack
    }

    var body: some View {
        VStack(spacing: 0) {
            BackBar(onBack: onBack)

            if let profile = viewModel.profile {
                content(profile)
            } else if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text(viewModel.errorMessage ?? L10n.homeErrorTitle)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        // 편집에서 돌아오면 닉네임이 바뀌어 있을 수 있다.
        .onChange(of: coordinator.path.last) { _, route in
            guard route == .profile else { return }
            Task { await viewModel.reload() }
        }
    }

    private func content(_ profile: UserProfile) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header(profile)
                    .padding(.horizontal, DSSpacing.s6)
                    .padding(.top, 8)
                    .padding(.bottom, 26)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(statCards(profile)) { card in
                        statCard(card)
                    }
                }
                .padding(.horizontal, DSSpacing.s6)

                if let stats = viewModel.stats {
                    contribution(stats)
                        .padding(.horizontal, DSSpacing.s6)
                        .padding(.top, 32)

                    records(stats)
                        .padding(.horizontal, DSSpacing.s6)
                        .padding(.top, 32)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 36)
        }
    }

    // MARK: - 헤더

    private func header(_ profile: UserProfile) -> some View {
        Button { onEdit(profile.user.nickname) } label: {
            HStack(spacing: 16) {
                Circle()
                    .fill(DSColor.brandPrimary)
                    .frame(width: 72, height: 72)
                    .overlay {
                        Text(String(profile.user.nickname.prefix(1)))
                            .font(DSTypography.font(27, weight: DSTypography.Weight.extrabold))
                            .foregroundStyle(Color.white)
                    }

                VStack(alignment: .leading, spacing: 0) {
                    Text(profile.user.nickname)
                        .font(DSTypography.font(26, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(1)

                    Text(subtitle(profile))
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)
                        .padding(.top, 7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                DSIconView(.chevronRight, size: 16, color: DSColor.textMuted)
            }
        }
        .buttonStyle(DSPressStyle())
    }

    private func subtitle(_ profile: UserProfile) -> String {
        guard let joined = viewModel.joinedLabel else { return profile.levelLabel }
        return "\(profile.levelLabel) · \(L10n.profileJoined(joined))"
    }

    // MARK: - 통계 카드

    private struct StatCard: Identifiable {
        let id: String
        let label: String
        let value: String
        let unit: String
        let note: String?
    }

    private func statCards(_ profile: UserProfile) -> [StatCard] {
        var cards: [StatCard] = [
            StatCard(
                id: "level",
                label: L10n.profileStatLevel,
                value: "Lv.\(profile.level)",
                unit: "",
                note: profile.levelLabel
            )
        ]

        guard let stats = viewModel.stats else { return cards }

        cards.append(
            StatCard(
                id: "regions",
                label: L10n.profileStatRegions,
                value: "\(stats.collectedRegions)",
                unit: L10n.profileUnitPlaces,
                note: L10n.profileStatRegionsNote(stats.totalRegions)
            )
        )
        cards.append(
            StatCard(
                id: "depopulated",
                label: L10n.profileStatDepopulated,
                value: "\(Int(stats.depopulatedVisitedPercent.rounded()))",
                unit: "%",
                note: "\(stats.depopulatedVisitedRegions) / \(stats.collectedRegions)"
            )
        )
        cards.append(
            StatCard(
                id: "distance",
                label: L10n.profileStatDistance,
                value: Self.distanceFormatter.string(from: NSNumber(value: Int(stats.totalDistanceKm.rounded()))) ?? "0",
                unit: "km",
                note: nil
            )
        )
        return cards
    }

    private static let distanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private func statCard(_ card: StatCard) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.label)
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(card.value)
                    .font(DSTypography.font(26, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.textPrimary)

                if !card.unit.isEmpty {
                    Text(card.unit)
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            .padding(.top, 8)

            if let note = card.note {
                Text(note)
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.regular))
                    .foregroundStyle(DSColor.textMuted)
                    .padding(.top, 6)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(DSColor.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - 소멸지역 기여도

    private func contribution(_ stats: ProfileStats) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.profileContributionTitle)
                .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.bottom, 14)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(stats.depopulatedVisitedRegions)")
                        .font(DSTypography.font(24, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.textPrimary)

                    Text(L10n.profileContributionOf(stats.collectedRegions))
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.bottom, 12)

                DSProgressBar(value: stats.depopulatedVisitedPercent, tone: .success)

                Text(L10n.profileContributionNote(stats.collectedRegions, stats.depopulatedVisitedRegions))
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
                    .foregroundStyle(DSColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)
            }
            .padding(20)
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(DSColor.border, lineWidth: 1)
            }
        }
    }

    // MARK: - 기록

    private func records(_ stats: ProfileStats) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.profileRecordsTitle)
                .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.bottom, 16)

            if let recent = stats.recentStamp {
                recordRow(icon: .clock, label: L10n.profileRecordRecentStamp, value: recent.regionName)
            }
            recordRow(icon: .sparkles, label: L10n.profileRecordBadges, value: L10n.profileCountItems(stats.badgeCount))
            recordRow(icon: .flame, label: L10n.profileRecordRank, value: "#\(stats.nationalRank)")
            recordRow(icon: .chat, label: L10n.profileRecordReviews, value: L10n.profileCountItems(stats.reviewCount))
        }
    }

    private func recordRow(icon: DSIcon, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            DSIconView(icon, size: 17, color: DSColor.brandPrimary)

            Text(label)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textSecondary)
                .lineLimit(1)
        }
        .padding(.vertical, 16)
        .overlay(alignment: .top) {
            Rectangle().fill(DSColor.border).frame(height: 1)
        }
    }
}
