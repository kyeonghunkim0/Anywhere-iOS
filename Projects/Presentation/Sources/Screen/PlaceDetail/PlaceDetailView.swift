//
//  PlaceDetailView.swift
//  Presentation
//
//  프로토타입에 없는 화면이다. 서버가 GET /api/places/{id}로 좌표·지역·태그·
//  도장수·후기를 한 번에 주게 되면서 생겼고, 생김새는 이미 있는 매칭 결과 화면
//  (지도 히어로 + 통계 줄)의 언어를 따른다.
//
//  "내 맘대로"로 고른 목적지도 이 화면으로 온다 — 그때만 도착 인증 버튼이 붙는다.
//

import SwiftUI
import MapKit
import Domain
import UIComponents

struct PlaceDetailView: View {
    @State private var viewModel: PlaceDetailViewModel
    /// "내 맘대로"에서 왔을 때만 붙는다 — confirmDestination()이 성공한 뒤 홈으로 돌아간다.
    private let onConfirmDestination: (() -> Void)?
    private let onBack: () -> Void
    private let onReportReview: (String) -> Void

    private let heroHeight: CGFloat = 300

    init(
        viewModel: PlaceDetailViewModel,
        onConfirmDestination: (() -> Void)? = nil,
        onBack: @escaping () -> Void = {},
        onReportReview: @escaping (String) -> Void = { _ in }
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onConfirmDestination = onConfirmDestination
        self.onBack = onBack
        self.onReportReview = onReportReview
    }

    var body: some View {
        Group {
            if let place = viewModel.place {
                content(place)
            } else if viewModel.isLoading {
                placeholder { ProgressView() }
            } else {
                placeholder {
                    VStack(spacing: DSSpacing.s4) {
                        Text(viewModel.errorMessage ?? L10n.homeErrorTitle)
                            .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                            .foregroundStyle(DSColor.textSecondary)

                        Button(L10n.arrivalRetry) { Task { await viewModel.retry() } }
                            .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                            .foregroundStyle(DSColor.brandPrimary)
                    }
                }
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .alert(
            L10n.homeErrorTitle,
            isPresented: Binding(
                get: { viewModel.place != nil && viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(L10n.commonConfirm, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func content(_ place: PlaceDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero(place)

                if !place.region.activeFestivals.isEmpty {
                    festivalBadges(place)
                        .padding(.horizontal, DSSpacing.s6)
                        .padding(.top, 16)
                }

                stats(place)

                if !place.tags.isEmpty {
                    tags(place)
                        .padding(.horizontal, DSSpacing.s6)
                        .padding(.top, 22)
                }

                infoRow(label: L10n.pickedPlaceAddressLabel, value: place.address)
                    .padding(.horizontal, DSSpacing.s6)
                    .padding(.top, 22)

                reviews(place)
                    .padding(.horizontal, DSSpacing.s6)
                    .padding(.top, 32)
            }
            .padding(.bottom, 36)
        }
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let onConfirmDestination {
                DSButton(L10n.matchResultConfirm, variant: .primary) {
                    Task {
                        if await viewModel.confirmDestination() {
                            onConfirmDestination()
                        }
                    }
                }
                .disabled(viewModel.isConfirming)
                .padding(.horizontal, DSSpacing.s6)
                .padding(.top, 16)
                .padding(.bottom, 32)
                .background(Color.white)
            }
        }
    }

    // MARK: - 히어로

    private func hero(_ place: PlaceDetail) -> some View {
        ZStack(alignment: .topLeading) {
            Map(
                position: .constant(
                    .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(
                                latitude: place.coordinate.latitude,
                                longitude: place.coordinate.longitude
                            ),
                            latitudinalMeters: 3_000,
                            longitudinalMeters: 3_000
                        )
                    )
                ),
                interactionModes: []
            )
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))

            LinearGradient(
                stops: [
                    .init(color: DSColor.ink900.opacity(0.5), location: 0),
                    .init(color: DSColor.ink900.opacity(0.18), location: 0.35),
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

                Text(place.name)
                    .font(DSTypography.font(30, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(Color.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(place.region.displayName)
                    .font(DSTypography.font(14, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.s6)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: heroHeight)
        .clipped()
    }

    // MARK: - 진행 중 축제

    private func festivalBadges(_ place: PlaceDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(place.region.activeFestivals) { festival in
                HStack(spacing: 8) {
                    DSIconView(.sparkles, size: 16, color: DSColor.brandPrimary)
                    Text(L10n.placeDetailFestivalActive(festival.name, max(festival.daysRemaining, 0)))
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.brandPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(DSColor.green50)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            }
        }
    }

    // MARK: - 통계 / 태그 / 후기

    private func stats(_ place: PlaceDetail) -> some View {
        HStack(alignment: .top, spacing: 0) {
            statColumn(label: L10n.placeDetailStampCount, value: "\(place.stampCount)")
            statColumn(label: L10n.placeDetailReviewCount, value: "\(place.reviewCount)")
            if place.region.isDepopulated {
                statColumn(label: L10n.matchResultRegionLabel, value: L10n.placeSearchDepopulated)
            }
        }
        .padding(.horizontal, DSSpacing.s6)
        .padding(.vertical, 22)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DSColor.border).frame(height: 1)
        }
    }

    private func statColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textSecondary)
            Text(value)
                .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tags(_ place: PlaceDetail) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(place.tags) { tag in
                    DSTag([tag.emoji, tag.label].compactMap { $0 }.joined(separator: " "), tone: .neutral)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.textSecondary)
            Text(value)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.bold))
                .foregroundStyle(DSColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(DSColor.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
    }

    private func reviews(_ place: PlaceDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.placeDetailReviewsTitle)
                .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.bottom, 16)

            if place.reviews.isEmpty {
                Text(L10n.placeDetailNoReviews)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 22)
                    .padding(.horizontal, 18)
                    .background(DSColor.surfaceSunken)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            } else {
                VStack(spacing: 10) {
                    ForEach(place.reviews) { review in
                        reviewRow(review)
                    }
                }
            }
        }
    }

    private func reviewRow(_ review: PlaceReview) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.nickname)
                    .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(DSColor.textPrimary)

                Spacer()

                Text(review.createdAt, format: .dateTime.year().month().day())
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.regular))
                    .foregroundStyle(DSColor.textMuted)

                Button(L10n.placeDetailReportReview) { onReportReview(review.id) }
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textMuted)
                    .padding(.leading, 8)
            }

            Text(review.content)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.regular))
                .foregroundStyle(DSColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(DSColor.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
    }

    private func placeholder<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) {
            BackBar(onBack: onBack)
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
