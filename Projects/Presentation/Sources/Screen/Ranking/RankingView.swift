//
//  RankingView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isRanking 화면. 탭으로 열리므로 상단 바와
//  탭바는 MainTabView가 그린다.
//  프로토타입의 "내 관심 로컬"(북마크)은 서버 API가 없어 옮기지 않는다.
//

import SwiftUI
import Domain
import UIComponents

struct RankingView: View {
    @State private var viewModel: RankingViewModel
    /// 프로토타입 기본값과 같다 — 이 앱이 미는 건 사람 순위가 아니라 지역 성장이다.
    @State private var segment = Segment.city.rawValue

    init(viewModel: RankingViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    private enum Segment: String {
        case city, user
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.rankingTitle)
                    .font(DSTypography.font(32, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.textPrimary)

                DSSegmentedControl(options: segments, selection: $segment)
                    .padding(.top, 20)

                if segment == Segment.user.rawValue {
                    userRanking
                } else {
                    cityGrowth
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.s6)
            .padding(.bottom, 36)
        }
        .background(Color.white)
        .task { await viewModel.load() }
    }

    private var segments: [DSSegmentedOption] {
        [
            .init(id: Segment.city.rawValue, label: L10n.rankingTabCity),
            .init(id: Segment.user.rawValue, label: L10n.rankingTabUser),
        ]
    }

    // MARK: - 도시 성장 게이지

    private var cityGrowth: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.rankingCityIntro)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textSecondary)
                .lineSpacing(DSTypography.lineSpacing(size: DSTypography.Size.base, leading: 1.65))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 24)

            if viewModel.growthRegions.isEmpty {
                emptyLine(L10n.rankingEmptyRegions)
                    .padding(.top, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.growthRegions) { region in
                        growthCard(region)
                    }
                }
                .padding(.top, 26)
            }
        }
    }

    private func growthCard(_ region: GrowthRegion) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.rankingLevelTag(region.level))
                .font(DSTypography.font(DSTypography.Size.xs2, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.green700)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(DSColor.green100)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            Text(region.fullName)
                .font(DSTypography.font(22, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.top, 14)

            DSProgressBar(value: region.progress, height: 6)
                .padding(.top, 14)

            Text(L10n.homeRemainingToLevelUp(region.remaining, region.level + 1))
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textSecondary)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        // 카드 바닥과 프로토타입의 커다란 배경 아이콘을 한 겹으로 깐다 —
        // 배경을 두 번 쌓으면 나중 것이 아이콘을 덮는다.
        .background(alignment: .bottomTrailing) {
            ZStack(alignment: .bottomTrailing) {
                DSColor.surfaceSunken
                DSIconView(region.regionId.regionIcon, size: 126, color: DSColor.brandPrimary)
                    .opacity(0.13)
                    .offset(x: 10, y: 16)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(DSColor.border, lineWidth: 1)
        }
    }

    // MARK: - 유저 랭킹

    private var userRanking: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let myRank = viewModel.myRank {
                myRankCard(myRank)
                    .padding(.top, 24)
            }

            Text(L10n.rankingTopWanderers)
                .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.top, 30)
                .padding(.bottom, 16)

            if viewModel.rankers.isEmpty {
                emptyLine(L10n.rankingEmptyUsers)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.rankers) { ranker in
                        rankerRow(ranker)
                    }
                }
            }
        }
    }

    private func myRankCard(_ myRank: MyRank) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.rankingMyRankLabel)
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(Color.white.opacity(0.72))

                Text(L10n.rankingRankValue(myRank.rank))
                    .font(DSTypography.font(30, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(Color.white)
                    .padding(.top, 8)

                Text(L10n.rankingMyRankTop(Float(myRank.topPercentage), myRank.totalUsers))
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .padding(.top, 6)
            }

            Spacer()

            DSIconView(.compass, size: 30, color: Color.white.opacity(0.85))
        }
        .padding(22)
        .background(DSColor.brandPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func rankerRow(_ ranker: UserRankItem) -> some View {
        HStack(spacing: 14) {
            Text("\(ranker.rank)")
                .font(DSTypography.font(16, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.brandPrimary)
                .frame(width: 24, alignment: .leading)

            Circle()
                .fill(DSColor.green50)
                .frame(width: 46, height: 46)
                .overlay {
                    Text(String(ranker.nickname.prefix(1)))
                        .font(DSTypography.font(17, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.brandPrimary)
                }

            VStack(alignment: .leading, spacing: 5) {
                Text(ranker.nickname)
                    .font(DSTypography.font(16, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)

                // 프로토타입의 "Lv.8 전국구 방랑자"는 서버가 주지 않는 값이라 도장 수만 쓴다.
                Text(L10n.rankingStampCount(ranker.totalStamps))
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 16)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(DSColor.border)
                .frame(height: 1)
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
}
