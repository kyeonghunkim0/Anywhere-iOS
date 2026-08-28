//
//  MatchResultView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isResult 화면.
//  프로토타입의 "주민 한마디"는 RandomMatch에 없는 값이라 옮기지 않는다.
//

import SwiftUI
import MapKit
import Domain
import UIComponents

struct MatchResultView: View {
    /// ViewModel은 이 뷰가 소유한다. 부모(RouteDestinationView) body가 다시 평가될 때마다
    /// 팩토리가 새 인스턴스를 만드는데, 참조만 들고 있으면 진행 중이던 상태가 통째로 버려진다
    /// — 화면은 로딩에서 멈추고 .task는 identity가 같아 다시 돌지도 않는다.
    @State private var viewModel: MatchResultViewModel
    private let onClose: () -> Void
    private let onConfirmed: () -> Void

    private let heroHeight: CGFloat = 420

    init(
        viewModel: MatchResultViewModel,
        onClose: @escaping () -> Void = {},
        onConfirmed: @escaping () -> Void = {}
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onClose = onClose
        self.onConfirmed = onConfirmed
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                stats
                actions
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            L10n.matchResultFailureTitle,
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

    // MARK: - Hero

    private var hero: some View {
        ZStack(alignment: .top) {
            map
            // 흰 글씨를 얹기 위한 어둠. 지도 원색이 그대로 드러나지 않는다.
            LinearGradient(
                stops: [
                    .init(color: DSColor.ink900.opacity(0.52), location: 0),
                    .init(color: DSColor.ink900.opacity(0.24), location: 0.30),
                    .init(color: DSColor.ink900.opacity(0.30), location: 0.62),
                    .init(color: DSColor.ink900.opacity(0.74), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            heroControls
            heroTitle
        }
        .frame(height: heroHeight)
        .clipped()
    }

    private var map: some View {
        Map(
            position: .constant(
                .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: viewModel.match.place.coordinate.latitude,
                            longitude: viewModel.match.place.coordinate.longitude
                        ),
                        latitudinalMeters: 4_000,
                        longitudinalMeters: 4_000
                    )
                )
            ),
            interactionModes: []
        )
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
    }

    private var heroControls: some View {
        HStack {
            Button(action: onClose) {
                DSIconView(.close, size: 16, color: DSColor.ink900)
                    .frame(width: 38, height: 38)
                    .background(DSColor.surface.opacity(0.92))
                    .clipShape(Circle())
            }
            .buttonStyle(DSPressStyle())
            .accessibilityLabel(L10n.commonClose)

            Spacer()

            HStack(spacing: 6) {
                DSIconView(.sparkles, size: 13, color: DSColor.brandPrimary)
                Text(L10n.matchResultRandomChip)
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.bold))
                    .foregroundStyle(DSColor.ink900)
            }
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(DSColor.surface.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.pill, style: .continuous))
        }
        .padding(.horizontal, 16)
        .padding(.top, 52)
    }

    private var heroTitle: some View {
        VStack(spacing: 10) {
            Text(viewModel.match.place.name)
                .font(DSTypography.font(38, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(Color.white)
                .lineSpacing(DSTypography.lineSpacing(size: 38, leading: 1.1))
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.match.region.displayName)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                .foregroundStyle(Color.white.opacity(0.88))
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, DSSpacing.s6)
        .frame(height: heroHeight)
    }

    // MARK: - Stats

    private var stats: some View {
        HStack(alignment: .top, spacing: 0) {
            statColumn(
                label: L10n.matchResultDistanceLabel,
                value: L10n.matchResultDistanceValue(Float(viewModel.match.distanceKm))
            )
            statColumn(
                label: L10n.matchResultRegionLabel,
                value: viewModel.match.region.displayName
            )
        }
        .padding(.horizontal, DSSpacing.s6)
        .padding(.vertical, 22)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(DSColor.border)
                .frame(height: 1)
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

    // MARK: - Actions

    private var actions: some View {
        VStack(spacing: 10) {
            if viewModel.match.region.isDepopulated {
                HStack(spacing: 8) {
                    DSIconView(.sprout, size: 16, color: DSColor.brandPrimary)
                    Text(L10n.matchResultDepopulatedBonus)
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.brandPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(DSColor.green50)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
                .padding(.bottom, 6)
            }

            DSButton(L10n.matchResultConfirm, variant: .primary) {
                Task { if await viewModel.confirm() { onConfirmed() } }
            }
            .disabled(viewModel.isWorking)

            DSButton(
                L10n.matchResultReroll(viewModel.remainingMatches),
                variant: .secondary
            ) {
                Task { await viewModel.reroll() }
            }
            .disabled(!viewModel.canReroll)
            .opacity(viewModel.canReroll ? 1 : 0.5)
        }
        .padding(.horizontal, DSSpacing.s6)
        .padding(.top, 28)
        .padding(.bottom, 32)
    }
}
