//
//  RankerDetailView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isRankerDetail 화면.
//  순위는 상세 API가 주지 않아 목록에서 눌린 순위를 그대로 들고 온다.
//

import SwiftUI
import Domain
import UIComponents

struct RankerDetailView: View {
    @State private var viewModel: RankerDetailViewModel
    private let rank: Int
    private let onBack: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    private let chartHeight: CGFloat = 110

    init(viewModel: RankerDetailViewModel, rank: Int, onBack: @escaping () -> Void = {}) {
        _viewModel = State(wrappedValue: viewModel)
        self.rank = rank
        self.onBack = onBack
    }

    var body: some View {
        VStack(spacing: 0) {
            BackBar(onBack: onBack)

            if let ranker = viewModel.ranker {
                content(ranker)
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: DSSpacing.s4) {
                    Text(viewModel.errorMessage ?? L10n.homeErrorTitle)
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)

                    Button(L10n.arrivalRetry) {
                        Task { await viewModel.retry() }
                    }
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                        .foregroundStyle(DSColor.brandPrimary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }

    private func content(_ ranker: RankerDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                profile(ranker)
                    .padding(.bottom, 28)

                dashboard(ranker)

                if !ranker.weeks.isEmpty {
                    monthlyActivity(ranker)
                        .padding(.top, 32)
                }

                if !ranker.stamps.isEmpty {
                    representativeStamps(ranker)
                        .padding(.top, 32)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.s6)
            .padding(.top, 8)
            .padding(.bottom, 36)
        }
    }

    // MARK: - 프로필

    private func profile(_ ranker: RankerDetail) -> some View {
        HStack(spacing: 16) {
            Circle()
                .fill(DSColor.brandPrimary)
                .frame(width: 72, height: 72)
                .overlay {
                    Text(String(ranker.nickname.prefix(1)))
                        .font(DSTypography.font(27, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(Color.white)
                }

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Text(ranker.nickname)
                        .font(DSTypography.font(24, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(1)

                    Text(L10n.rankingRankValue(rank))
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.brandPrimary)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 9)
                        .background(DSColor.green50)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.pill, style: .continuous))
                }

                Text(ranker.levelLabel)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.top, 7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 요약 지표

    private func dashboard(_ ranker: RankerDetail) -> some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(ranker.dash) { item in
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.label)
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)

                    Text(item.value)
                        .font(DSTypography.font(24, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.textPrimary)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(DSColor.surfaceSunken)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    // MARK: - 이번 달 활동

    private func monthlyActivity(_ ranker: RankerDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.rankerDetailMonthlyTitle)
                .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.bottom, 16)

            HStack(alignment: .bottom, spacing: 7) {
                ForEach(ranker.weeks) { week in
                    VStack(spacing: 7) {
                        Spacer(minLength: 0)

                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(week.count > 0 ? DSColor.brandPrimary : DSColor.sand200)
                            .frame(height: barHeight(for: week.count))

                        Text(week.label)
                            .font(DSTypography.font(10, weight: DSTypography.Weight.semibold))
                            .foregroundStyle(DSColor.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: chartHeight)
            .padding(18)
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(DSColor.border, lineWidth: 1)
            }
        }
    }

    /// 라벨 줄과 여백을 뺀 나머지를 가장 바쁜 주에 다 준다. 0회인 주도 실선은 남긴다.
    private func barHeight(for count: Int) -> CGFloat {
        let available = chartHeight - 36 - 14 - 7
        guard viewModel.busiestWeek > 0 else { return 3 }
        return max(3, available * CGFloat(count) / CGFloat(viewModel.busiestWeek))
    }

    // MARK: - 대표 도장

    private func representativeStamps(_ ranker: RankerDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.rankerDetailStampsTitle)
                .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.bottom, 18)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(ranker.stamps) { stamp in
                    VStack(spacing: 8) {
                        DSIconView(stamp.regionId.regionIcon, size: 22, color: DSColor.brandPrimary)
                            .frame(width: 56, height: 56)
                            .background(DSColor.green50)
                            .clipShape(Circle())
                            .overlay {
                                Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 2)
                            }

                        Text(stamp.sigunguName)
                            .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.bold))
                            .foregroundStyle(DSColor.textPrimary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}
