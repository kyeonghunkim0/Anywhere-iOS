//
//  PassportView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isPassport 화면. 탭으로 열리므로 상단 바와
//  탭바는 MainTabView가 그린다 — 이 화면은 내용만 그린다.
//  프로토타입의 여권 번호(AMD-2026-0412)는 서버 계약에 없는 값이라 옮기지 않는다.
//  이 화면은 "가진 것"만 보여준다 — 아직 못 얻은 뱃지와 못 간 지역은 상세 화면 몫이다.
//

import SwiftUI
import Domain
import UIComponents

struct PassportView: View {
    @State private var viewModel: PassportViewModel
    private let onOpenDetail: (PassportSection) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    init(
        viewModel: PassportViewModel,
        onOpenDetail: @escaping (PassportSection) -> Void = { _ in }
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onOpenDetail = onOpenDetail
    }

    var body: some View {
        VStack(spacing: 0) {
            if let passport = viewModel.passport {
                content(passport)
            } else if viewModel.isLoading {
                centered { ProgressView() }
            } else {
                centered {
                    Text(L10n.homeErrorTitle)
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
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
            Button(L10n.arrivalRetry) { Task { await viewModel.retry() } }
            Button(L10n.commonConfirm, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func content(_ passport: Passport) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.passportTitle)
                    .font(DSTypography.font(32, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.textPrimary)

                passportCard(passport)
                    .padding(.top, 22)

                badgeSection
                    .padding(.top, 34)

                collectionBoard(passport)
                    .padding(.top, 36)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.s6)
            .padding(.bottom, 36)
        }
    }

    // MARK: - 여권 카드

    private func passportCard(_ passport: Passport) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.passportCardLabel)
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                .foregroundStyle(Color.white.opacity(0.72))

            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(passport.visitedRegions)")
                    .font(DSTypography.font(38, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(Color.white)

                Text(L10n.passportOutOf(passport.totalRegions))
                    .font(DSTypography.font(14, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(Color.white.opacity(0.72))
            }
            .padding(.top, 8)

            progressBar
                .padding(.top, 20)

            if let lastStamp = viewModel.lastStamp {
                Text(lastStamp)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .padding(.top, 14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.s6)
        .background(DSColor.brandPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.24))
                Capsule()
                    .fill(Color.white)
                    .frame(width: proxy.size.width * viewModel.progress)
            }
        }
        .frame(height: 6)
    }

    // MARK: - 수집판

    private func collectionBoard(_ passport: Passport) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(
                title: L10n.passportBoardTitle,
                trailing: "\(passport.visitedRegions) / \(passport.totalRegions)",
                section: .regions
            )
            .padding(.bottom, 20)

            if viewModel.collectedStamps.isEmpty {
                emptyLine(L10n.passportEmptyRegions)
            } else {
                LazyVGrid(columns: columns, spacing: 22) {
                    ForEach(viewModel.collectedStamps) { region in
                        DSStampTile(
                            icon: region.stampIcon,
                            name: region.displayName,
                            isCollected: true,
                            visitorNumber: region.visitorNumber
                        )
                    }
                }
            }
        }
    }

    // MARK: - 뱃지

    private var badgeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(
                title: L10n.passportBadgeTitle,
                trailing: "\(viewModel.earnedBadges.count) / \(viewModel.badges.count)",
                section: .badges
            )

            Text(L10n.passportBadgeSubtitle)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
                .foregroundStyle(DSColor.textSecondary)
                .padding(.top, 6)
                .padding(.bottom, 18)

            if viewModel.earnedBadges.isEmpty {
                emptyLine(L10n.passportEmptyBadges)
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.earnedBadges) { badge in
                            badgeCard(badge)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                // 카드가 화면 가장자리까지 흐르도록 좌우 여백을 잠깐 무른다.
                .padding(.horizontal, -DSSpacing.s6)
                .contentMargins(.horizontal, DSSpacing.s6, for: .scrollContent)
            }
        }
    }

    /// 섹션 제목 + "전체 보기". 못 얻은 것은 여기서 안 보여주므로 들어갈 길을 남긴다.
    private func sectionHeader(title: String, trailing: String, section: PassportSection) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)

            Spacer()

            Button { onOpenDetail(section) } label: {
                HStack(spacing: 6) {
                    Text(trailing)
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)
                    DSIconView(.chevronRight, size: 12, color: DSColor.brandPrimary)
                }
            }
            .buttonStyle(DSPressStyle())
        }
    }

    private func emptyLine(_ text: String) -> some View {
        Text(text)
            .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
            .foregroundStyle(DSColor.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 22)
            .padding(.horizontal, 18)
            .background(DSColor.surfaceSunken)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
    }

    private func badgeCard(_ badge: Badge) -> some View {
        VStack(spacing: 0) {
            BadgeIcon(badge: badge, diameter: 56)
            .background(Color.white)
            .clipShape(Circle())
            .opacity(badge.isUnlocked ? 1 : 0.45)

            Text(badge.name)
                .font(DSTypography.font(14, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(badge.isUnlocked ? DSColor.textPrimary : DSColor.textMuted)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.top, 14)

            Text(badge.stateLabel)
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                .foregroundStyle(badge.isUnlocked ? DSColor.brandPrimary : DSColor.textMuted)
                .padding(.top, 6)
        }
        .frame(width: 148)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(DSColor.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
