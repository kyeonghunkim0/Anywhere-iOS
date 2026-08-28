//
//  HomeView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isHome 화면.
//  프로토타입의 D-day/캐러셀 진행률·"이번 주 방문 N명"·예상 도착 시간 같은 문구는
//  서버가 내려주지 않는 값이라 그대로 옮기지 않는다 — 실제 API가 주는 필드만 쓴다.
//

import SwiftUI
import Domain
import UIComponents

public struct HomeView: View {
    @Bindable private var viewModel: HomeViewModel
    private let onStartTrip: () -> Void
    private let onVerifyArrival: (Place) -> Void

    public init(
        viewModel: HomeViewModel,
        onStartTrip: @escaping () -> Void = {},
        onVerifyArrival: @escaping (Place) -> Void = { _ in }
    ) {
        self.viewModel = viewModel
        self.onStartTrip = onStartTrip
        self.onVerifyArrival = onVerifyArrival
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let trip = viewModel.currentTrip {
                    tripCard(trip)
                } else {
                    heroCard
                }
                if !viewModel.seasonalBadges.isEmpty {
                    specialQuests
                }
                if !viewModel.growthRegions.isEmpty {
                    trendingLocal
                }
            }
        }
        .refreshable { await viewModel.reload() }
        .background(Color.white)
        .task { await viewModel.load() }
        .alert(
            L10n.locationPermissionTitle,
            isPresented: $viewModel.locationPermissionDenied
        ) {
            Button(L10n.locationOpenSettings) { openSettings() }
            Button(L10n.commonCancel, role: .cancel) {}
        } message: {
            Text(L10n.locationPermissionDenied)
        }
        .alert(
            L10n.homeErrorTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }
            )
        ) {
            Button(L10n.commonConfirm) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func tripCard(_ trip: CurrentTrip) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                Circle()
                    .fill(DSColor.brandPrimary)
                    .frame(width: 9, height: 9)
                Text(L10n.homeTripBadge)
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.brandPrimary)
                Spacer()
                Text(L10n.homeTripDistance(Float(trip.distanceKm)))
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.regular))
                    .foregroundStyle(DSColor.textSecondary)
            }

            Text(trip.place.name)
                .font(DSTypography.font(DSTypography.Size.xl, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.top, 16)

            Text(trip.region.fullName)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
                .foregroundStyle(DSColor.textSecondary)
                .padding(.top, 6)

            Button { onVerifyArrival(trip.place) } label: {
                Text(L10n.homeVerifyArrival)
                    .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.bold))
                    .foregroundStyle(DSColor.textOnBrand)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(DSColor.surfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            }
            .buttonStyle(DSPressStyle())
            .padding(.top, 20)

            Button(action: viewModel.cancelTrip) {
                Text(L10n.homeCancelTrip)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
                    .foregroundStyle(DSColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .padding(.top, 10)
        }
        .padding(20)
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.xl, style: .continuous)
                .strokeBorder(DSColor.border, lineWidth: 1)
        }
        .padding(.top, 22)
        .padding(.horizontal, DSSpacing.s6)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.homeHeroTitle)
                .font(DSTypography.font(34, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .lineSpacing(DSTypography.lineSpacing(size: 34, leading: 1.16))

            Text(L10n.homeHeroSubtitle)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.regular))
                .foregroundStyle(DSColor.textSecondary)
                .lineSpacing(DSTypography.lineSpacing(size: DSTypography.Size.base, leading: DSTypography.Leading.relaxed))
                .padding(.top, 14)

            Button {
                Task {
                    if await viewModel.prepareTrip() { onStartTrip() }
                }
            } label: {
                HStack(spacing: 8) {
                    DSIconView(.compass, size: 18, color: DSColor.textOnBrand)
                    Text(L10n.homeStartTrip)
                        .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.bold))
                        .foregroundStyle(DSColor.textOnBrand)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(DSColor.brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            }
            .buttonStyle(DSPressStyle())
            .padding(.top, 22)
        }
        .padding(.top, 28)
        .padding(.horizontal, DSSpacing.s6)
    }

    private var specialQuests: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .lastTextBaseline) {
                Text(L10n.homeSpecialQuests)
                    .font(DSTypography.font(22, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.textPrimary)
                Spacer()
                Text(L10n.homeLimitedTime)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                    .foregroundStyle(DSColor.brandAccent)
            }
            .padding(.trailing, DSSpacing.s6)
            .padding(.bottom, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(viewModel.seasonalBadges) { badge in
                        QuestCard(badge: badge)
                    }
                }
                .padding(.trailing, DSSpacing.s6)
            }
        }
        .padding(.top, 34)
        .padding(.leading, DSSpacing.s6)
    }

    private var trendingLocal: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .lastTextBaseline) {
                Text(L10n.homeTrendingLocal)
                    .font(DSTypography.font(22, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.textPrimary)
                Spacer()
                Text(L10n.homeLevelUpSoon)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
                    .foregroundStyle(DSColor.textSecondary)
            }
            .padding(.bottom, 16)

            ForEach(viewModel.growthRegions) { region in
                GrowthRegionRow(region: region)
            }
        }
        .padding(.top, 36)
        .padding(.horizontal, DSSpacing.s6)
    }
}

private struct QuestCard: View {
    let badge: Badge

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.homeLimitedTime)
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.brandAccent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(DSColor.stamp400.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.pill, style: .continuous))

            Text(badge.name)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)

            Text(badge.description)
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.regular))
                .foregroundStyle(DSColor.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)

            if let daysRemaining = badge.daysRemaining {
                Text("D-\(daysRemaining)")
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.brandAccent)
                    .padding(.top, 10)
            }
        }
        .padding(16)
        // 높이를 고정하지 않는다. 고정하면 문구가 짧을 땐 빈 공간이 남고
        // 길어지면 잘린다 — 뱃지 문구는 서버가 정하므로 어느 쪽도 못 막는다.
        // 카드끼리의 높이는 문구 줄 수가 같으면 저절로 맞는다.
        .frame(width: 200, alignment: .topLeading)
        .background(DSColor.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.xl, style: .continuous))
    }
}

private struct GrowthRegionRow: View {
    let region: GrowthRegion

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(DSColor.green50)
                .frame(width: 64, height: 64)
                .overlay {
                    DSIconView(.sprout, size: 26, color: DSColor.brandPrimary)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(region.fullName)
                    .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.textPrimary)

                Text(L10n.homeRemainingToLevelUp(region.remaining, region.level + 1))
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.regular))
                    .foregroundStyle(DSColor.textSecondary)

                DSProgressBar(value: progressPercent, tone: .success, height: 5)
            }

            DSIconView(.chevronRight, size: 14, color: DSColor.textSecondary)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .top) {
            Rectangle().fill(DSColor.border).frame(height: 1)
        }
    }

    private var progressPercent: Double {
        let target = Double(region.current + region.remaining)
        guard target > 0 else { return 0 }
        return Double(region.current) / target * 100
    }
}

#Preview {
    HomeView(viewModel: .preview)
}

private extension HomeViewModel {
    /// Xcode Preview 전용. 실제 앱에서는 DIContainer가 조립한 인스턴스를 주입받는다.
    static var preview: HomeViewModel {
        struct NoopMatchRepository: MatchRepository {
            func fetchRandomMatch(at: Coordinate, radiusKm: Double?, tagId: String?) async throws(MatchError) -> RandomMatch {
                throw .network(.unknown)
            }
            func confirmMatch(matchId: String) async throws(MatchError) -> CurrentTrip {
                throw .network(.unknown)
            }
            func cancelMatch(matchId: String) async throws(MatchError) {}
            func fetchCurrentTrip() async throws(MatchError) -> CurrentTrip? { nil }
        }
        struct NoopBadgeRepository: BadgeRepository {
            func fetchMyBadges() async throws(NetworkError) -> [Badge] { [] }
            func fetchSeasonalBadges() async throws(NetworkError) -> [Badge] { [] }
        }
        struct NoopRegionRepository: RegionRepository {
            func fetchGrowthRegions(limit: Int?) async throws(NetworkError) -> [GrowthRegion] { [] }
            func fetchRegionDetail(regionId: String) async throws(NetworkError) -> RegionDetail {
                throw .unknown
            }
        }
        struct NoopLocationRepository: LocationRepository {
            func authorizationStatus() async -> LocationAuthorization { .authorized }
            func requestAuthorization() async -> LocationAuthorization { .authorized }
            func currentCoordinate() async throws(LocationError) -> Coordinate {
                throw .unableToLocate
            }
        }
        return HomeViewModel(
            user: User(id: "preview", nickname: "로컬탐험가", socialType: "google", totalStamps: 12),
            fetchCurrentTripUseCase: FetchCurrentTripUseCase(matchRepository: NoopMatchRepository()),
            fetchSeasonalBadgesUseCase: FetchSeasonalBadgesUseCase(badgeRepository: NoopBadgeRepository()),
            fetchGrowthRegionsUseCase: FetchGrowthRegionsUseCase(regionRepository: NoopRegionRepository()),
            cancelMatchUseCase: CancelMatchUseCase(matchRepository: NoopMatchRepository()),
            requestLocationPermissionUseCase: RequestLocationPermissionUseCase(
                locationRepository: NoopLocationRepository()
            )
        )
    }
}
