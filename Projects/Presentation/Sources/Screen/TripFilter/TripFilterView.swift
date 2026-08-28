//
//  TripFilterView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isFilter 화면.
//  거리 선택은 서버를 부르지 않는 순수 로컬 상태라 ViewModel을 두지 않는다.
//  "내 맘대로"만 예외로 장소 검색 화면을 거치므로 선택 결과를 TripPlanModel로 주고받는다.
//

import SwiftUI
import UIComponents

struct TripFilterView: View {
    private let onBack: () -> Void
    private let onStart: (TripRange) -> Void
    private let onPickMyself: () -> Void
    private let onStartCustom: () -> Void

    @Environment(TripPlanModel.self) private var plan

    init(
        onBack: @escaping () -> Void = {},
        onStart: @escaping (TripRange) -> Void = { _ in },
        onPickMyself: @escaping () -> Void = {},
        onStartCustom: @escaping () -> Void = {}
    ) {
        self.onBack = onBack
        self.onStart = onStart
        self.onPickMyself = onPickMyself
        self.onStartCustom = onStartCustom
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BackBar(onBack: onBack)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n.tripFilterTitle)
                        .font(DSTypography.font(34, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(L10n.tripFilterDistanceQuestion)
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                        .foregroundStyle(DSColor.textSecondary)
                        .padding(.top, 16)
                        .padding(.bottom, 10)

                    VStack(spacing: 8) {
                        ForEach(TripRange.allCases) { range in
                            rangeRow(range)
                        }
                    }

                    if plan.isCustom {
                        customHint
                            .padding(.top, 14)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.s6)
                .padding(.top, 8)
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            cta
                .padding(.horizontal, DSSpacing.s6)
                .padding(.top, 16)
                .background(Color.white)
        }
    }

    // MARK: - CTA

    /// "내 맘대로"는 목적지를 고르기 전까지 떠날 수 없다 — 그 상태를 secondary로 표시한다.
    @ViewBuilder
    private var cta: some View {
        if plan.isCustom {
            if let picked = plan.pickedPlace {
                DSButton(L10n.tripFilterStartCustom(picked.name), variant: .primary, action: onStartCustom)
            } else {
                DSButton(L10n.tripFilterPickPrompt, variant: .secondary, action: onPickMyself)
            }
        } else {
            DSButton(L10n.homeStartTrip, variant: .primary) {
                onStart(plan.range)
            }
        }
    }

    private var customHint: some View {
        Text(
            plan.pickedPlace.map { L10n.tripFilterCustomHintPicked($0.name) }
                ?? L10n.tripFilterCustomHintEmpty
        )
        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
        .foregroundStyle(DSColor.textSecondary)
        .lineSpacing(DSTypography.lineSpacing(size: DSTypography.Size.sm, leading: 1.5))
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(DSColor.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                .strokeBorder(DSColor.border, lineWidth: 1)
        }
    }

    // MARK: - Rows

    private func rangeRow(_ range: TripRange) -> some View {
        let isSelected = plan.range == range

        return Button {
            plan.range = range
            // 이미 고른 상태에서 다시 눌러도 검색 화면으로 간다 — 목적지를 바꾸는 유일한 경로다.
            if range.opensPlaceSearch { onPickMyself() }
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(range.title)
                        .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(isSelected ? DSColor.brandPrimary : DSColor.textPrimary)

                    Text(range.subtitle)
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(isSelected ? DSColor.brandPrimary : DSColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if range.opensPlaceSearch {
                    DSIconView(
                        .chevronRight,
                        size: 15,
                        color: isSelected ? DSColor.brandPrimary : DSColor.textPrimary
                    )
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(isSelected ? DSColor.green50 : DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                    .strokeBorder(isSelected ? DSColor.brandPrimary : DSColor.border, lineWidth: 1)
            }
        }
        .buttonStyle(DSPressStyle())
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    TripFilterView()
        .environment(TripPlanModel())
}
