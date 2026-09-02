//
//  RegionDetailView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isRegionDetail 화면.
//  프로토타입의 히어로는 OSM 지도 타일이지만, 서버가 지역 대표 사진(imageUrl)을
//  내려주므로 그쪽을 쓴다 — 저작자 표기 자리도 프로토타입의 지도 출처 자리와 같다.
//  ★ 북마크는 저장할 API가 없어 옮기지 않는다.
//

import SwiftUI
import Domain
import UIComponents

struct RegionDetailView: View {
    @State private var viewModel: RegionDetailViewModel
    private let onBack: () -> Void

    private let heroHeight: CGFloat = 300

    init(viewModel: RegionDetailViewModel, onBack: @escaping () -> Void = {}) {
        _viewModel = State(wrappedValue: viewModel)
        self.onBack = onBack
    }

    var body: some View {
        Group {
            if let region = viewModel.region {
                content(region)
            } else if viewModel.isLoading {
                loading
            } else {
                failure
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }

    private func content(_ region: RegionDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero(region)

                gauge(region)
                    .padding(.horizontal, DSSpacing.s6)
                    .padding(.top, 24)

                stats(region)
                    .padding(DSSpacing.s6)

                levels(region)
                    .padding(.horizontal, DSSpacing.s6)

                if let quote = region.quote, !quote.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(L10n.regionDetailQuoteTitle)
                            .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.extrabold))
                            .foregroundStyle(DSColor.textPrimary)
                            .padding(.bottom, 14)

                        DSQuoteCallout(quote)
                    }
                    .padding(.horizontal, DSSpacing.s6)
                    .padding(.top, 32)
                }
            }
            .padding(.bottom, 36)
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - 히어로

    private func hero(_ region: RegionDetail) -> some View {
        ZStack(alignment: .topLeading) {
            image(region)

            LinearGradient(
                stops: [
                    .init(color: DSColor.ink900.opacity(0.5), location: 0),
                    .init(color: DSColor.ink900.opacity(0.2), location: 0.38),
                    .init(color: DSColor.ink900.opacity(0.74), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            Button(action: onBack) {
                DSIconView(.chevronRight, size: 17, color: DSColor.ink900)
                    .rotationEffect(.degrees(180))
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Circle())
            }
            .buttonStyle(DSPressStyle())
            .accessibilityLabel(L10n.commonBack)
            .padding(.leading, 16)
            .padding(.top, 52)

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Text(region.displayName)
                    .font(DSTypography.font(32, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(Color.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle(region))
                    .font(DSTypography.font(14, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.s6)
            .padding(.bottom, 24)

            if let credit = region.imageCredit, !credit.isEmpty {
                Text(L10n.regionDetailImageCredit(credit))
                    .font(DSTypography.font(9, weight: DSTypography.Weight.regular))
                    .foregroundStyle(Color.white.opacity(0.62))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 14)
                    .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: heroHeight)
        .clipped()
    }

    /// 사진은 반드시 고정 크기 안에 가둔다 — scaledToFill을 그대로 두면 사진 원본
    /// 비율만큼 히어로가 넓어지고, 그 폭에 맞춰 화면 전체가 좌우로 밀린다.
    private func image(_ region: RegionDetail) -> some View {
        Rectangle()
            .fill(DSColor.sand100)
            .overlay {
                if let url = region.imageURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.clear
                    }
                }
            }
            .clipped()
    }

    private func subtitle(_ region: RegionDetail) -> String {
        region.isDepopulated
            ? L10n.regionDetailLevelDepopulated(region.level)
            : L10n.regionDetailLevel(region.level)
    }

    // MARK: - 성장 게이지

    private func gauge(_ region: RegionDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(L10n.regionDetailVisitors(region.current))
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                    .foregroundStyle(DSColor.textPrimary)

                Spacer()

                if let target = region.target {
                    Text(L10n.regionDetailTarget(target))
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            .padding(.bottom, 10)

            DSProgressBar(value: region.progress, tone: .success)

            Text(region.remainLabel)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.brandPrimary)
                .padding(.top, 12)
        }
    }

    // MARK: - 통계

    private func stats(_ region: RegionDetail) -> some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(region.stats) { stat in
                VStack(alignment: .leading, spacing: 6) {
                    Text(stat.label)
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)
                    Text(stat.value)
                        .font(DSTypography.font(19, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - 레벨 달성 현황

    private func levels(_ region: RegionDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 레벨마다 뱃지를 새로 만들지 않는다 — 뱃지는 한 장이고,
            // 둘레의 5칸 링이 차오르는 것으로 레벨을 보여준다.
            // 그래서 서버가 주는 레벨별 보상 문구(row.reward: "한정판 뱃지" 등)는
            // 지킬 수 없는 약속이라 그리지 않는다.
            HStack(spacing: 14) {
                RegionBadgeIcon(
                    badge: region.badge,
                    name: region.displayName,
                    seed: region.regionId,
                    level: region.level,
                    diameter: 68
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.regionDetailLevelsTitle)
                        .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.textPrimary)

                    // 히어로가 이미 레벨을 말하므로 여기서는 링이 몇 칸짜리인지만 밝힌다.
                    Text("\(L10n.regionDetailLevel(region.level)) / \(DSRegionBadge.maxLevel)")
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            .padding(.bottom, 16)

            ForEach(region.levels) { row in
                HStack(spacing: 12) {
                    DSIconView(
                        row.icon,
                        size: 17,
                        color: row.achieved ? DSColor.brandPrimary : DSColor.textMuted
                    )

                    Text(row.label)
                        .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(row.achieved ? DSColor.textPrimary : DSColor.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 16)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(DSColor.border)
                        .frame(height: 1)
                }
            }
        }
    }

    // MARK: - 로딩 / 실패

    private var loading: some View {
        VStack(spacing: 0) {
            BackBar(onBack: onBack)
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var failure: some View {
        VStack(spacing: 0) {
            BackBar(onBack: onBack)
            VStack(spacing: DSSpacing.s4) {
                Text(viewModel.errorMessage ?? L10n.homeErrorTitle)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textSecondary)

                Button(L10n.arrivalRetry) { Task { await viewModel.retry() } }
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                    .foregroundStyle(DSColor.brandPrimary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
