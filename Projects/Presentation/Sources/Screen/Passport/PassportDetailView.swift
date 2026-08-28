//
//  PassportDetailView.swift
//  Presentation
//
//  여권 탭이 "가진 것"만 보여주는 대신, 전체 목록은 여기서 본다 —
//  아직 못 간 지역과 못 얻은 뱃지가 잠긴 모습으로 함께 나온다.
//

import SwiftUI
import Domain
import UIComponents

/// 여권에서 펼쳐 볼 수 있는 두 묶음.
public enum PassportSection: String, Hashable, Sendable {
    case regions
    case badges
}

struct PassportDetailView: View {
    @State private var viewModel: PassportViewModel
    private let section: PassportSection
    private let onBack: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    init(
        viewModel: PassportViewModel,
        section: PassportSection,
        onBack: @escaping () -> Void = {}
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.section = section
        self.onBack = onBack
    }

    var body: some View {
        VStack(spacing: 0) {
            BackBar(title: title, onBack: onBack)

            if viewModel.isLoading && viewModel.passport == nil {
                centered { ProgressView() }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(summary)
                            .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                            .foregroundStyle(DSColor.textSecondary)
                            .padding(.bottom, 20)

                        switch section {
                        case .regions: regionGrid
                        case .badges: badgeList
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DSSpacing.s6)
                    .padding(.top, 8)
                    .padding(.bottom, 36)
                }
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }

    private var title: String {
        switch section {
        case .regions: L10n.passportBoardTitle
        case .badges: L10n.passportBadgeTitle
        }
    }

    private var summary: String {
        switch section {
        case .regions:
            guard let passport = viewModel.passport else { return "" }
            return L10n.passportDetailRegionSummary(passport.visitedRegions, passport.totalRegions)
        case .badges:
            return L10n.passportDetailBadgeSummary(viewModel.earnedBadges.count, viewModel.badges.count)
        }
    }

    private var regionGrid: some View {
        LazyVGrid(columns: columns, spacing: 22) {
            ForEach(viewModel.allStamps) { region in
                DSStampTile(
                    icon: region.stampIcon,
                    name: region.sigunguName,
                    isCollected: region.isVisited,
                    visitorNumber: region.visitorNumber
                )
            }
        }
    }

    private var badgeList: some View {
        LazyVStack(spacing: 8) {
            ForEach(viewModel.allBadges) { badge in
                badgeRow(badge)
            }
        }
    }

    private func badgeRow(_ badge: Badge) -> some View {
        HStack(spacing: 14) {
            DSIconView(
                badge.stampIcon,
                size: 22,
                color: badge.isUnlocked ? DSColor.brandAccent : DSColor.textMuted
            )
            .frame(width: 48, height: 48)
            .background(badge.isUnlocked ? Color.white : DSColor.sand100)
            .clipShape(Circle())
            .opacity(badge.isUnlocked ? 1 : 0.55)

            VStack(alignment: .leading, spacing: 4) {
                Text(badge.name)
                    .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(badge.isUnlocked ? DSColor.textPrimary : DSColor.textMuted)

                // 못 얻은 뱃지는 설명이 곧 힌트다. 서버가 위치를 감춘 히든 뱃지도 설명은 준다.
                Text(badge.description.isEmpty ? badge.stateLabel : badge.description)
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.regular))
                    .foregroundStyle(DSColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if badge.isUnlocked {
                DSIconView(.check, size: 16, color: DSColor.brandPrimary)
            } else {
                DSIconView(.lock, size: 14, color: DSColor.textMuted)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(badge.isUnlocked ? DSColor.green50 : DSColor.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
    }

    private func centered<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack {
            Spacer()
            content()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
