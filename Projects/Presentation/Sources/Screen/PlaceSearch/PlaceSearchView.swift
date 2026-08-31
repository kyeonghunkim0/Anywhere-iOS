//
//  PlaceSearchView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isSpotSearch 화면.
//  "내 맘대로"로 들어오는 목적지 직접 선택. 고른 결과는 조건 화면이 이어받으므로
//  선택 상태는 이 화면이 아니라 TripPlanModel에 쓴다.
//

import SwiftUI
import Domain
import UIComponents

struct PlaceSearchView: View {
    @State private var viewModel: PlaceSearchViewModel
    private let onBack: () -> Void
    private let onDone: () -> Void

    @Environment(TripPlanModel.self) private var plan
    @FocusState private var isFieldFocused: Bool

    init(
        viewModel: PlaceSearchViewModel,
        onBack: @escaping () -> Void = {},
        onDone: @escaping () -> Void = {}
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onBack = onBack
        self.onDone = onDone
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            content
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            cta
                .padding(.horizontal, DSSpacing.s6)
                .padding(.top, 16)
                .background(Color.white)
        }
        .task { await viewModel.load() }
        .alert(
            L10n.placeSearchFailureTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(L10n.placeSearchRetry) { Task { await viewModel.retry() } }
            Button(L10n.commonCancel, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Search bar

    /// 프로토타입처럼 뒤로가기와 검색창이 같은 줄에 붙는다 — 별도 타이틀 줄을 두지 않는다.
    private var searchBar: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                DSIconView(.chevronRight, size: 18, color: DSColor.ink900)
                    .rotationEffect(.degrees(180))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(DSPressStyle())
            .accessibilityLabel(L10n.commonBack)

            HStack(spacing: 10) {
                DSIconView(.target, size: 16, color: DSColor.sand600)

                TextField("", text: $viewModel.keyword)
                    .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textPrimary)
                    .focused($isFieldFocused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    // 기본 placeholder 색이 sunken 배경 위에서 거의 안 보여 직접 겹쳐 둔다.
                    .overlay(alignment: .leading) {
                        if !viewModel.hasKeyword {
                            Text(L10n.placeSearchFieldPlaceholder)
                                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.semibold))
                                .foregroundStyle(DSColor.textSecondary)
                                .allowsHitTesting(false)
                        }
                    }

                if viewModel.hasKeyword {
                    Button {
                        viewModel.keyword = ""
                    } label: {
                        DSIconView(.close, size: 11, color: DSColor.sand700)
                            .frame(width: 22, height: 22)
                            .background(DSColor.sand200)
                            .clipShape(Circle())
                    }
                    .buttonStyle(DSPressStyle())
                    .accessibilityLabel(L10n.commonClose)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(DSColor.surfaceSunken)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                    .strokeBorder(DSColor.border, lineWidth: 1)
            }
            .padding(.trailing, 12)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }

    // MARK: - List

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            centered { ProgressView() }
        } else if viewModel.isEmptyResult {
            centered {
                Text(L10n.placeSearchEmpty)
                    .font(DSTypography.font(14, weight: DSTypography.Weight.semibold))
                    .foregroundStyle(DSColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(DSTypography.lineSpacing(size: 14, leading: 1.6))
            }
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.listHeading)
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.bold))
                        .foregroundStyle(DSColor.sand600)
                        .padding(.bottom, 4)

                    ForEach(viewModel.results) { place in
                        row(place)
                    }
                }
                .padding(.horizontal, DSSpacing.s6)
                .padding(.bottom, DSSpacing.s8)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    private func row(_ place: TaggedPlace) -> some View {
        let isPicked = plan.pickedPlace?.id == place.id

        return Button {
            isFieldFocused = false
            // 다시 누르면 해제된다 — 프로토타입과 같은 토글이다.
            plan.pickedPlace = isPicked ? nil : place
        } label: {
            HStack(spacing: 12) {
                DSIconView(
                    place.isDepopulated ? .sprout : .pin,
                    size: 18,
                    color: isPicked ? DSColor.brandPrimary : DSColor.sand600
                )
                .frame(width: 36, height: 36)
                .background(DSColor.sand100)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name)
                        .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(isPicked ? DSColor.brandPrimary : DSColor.textPrimary)
                        .lineLimit(1)

                    Text("\(place.displayName) · \(place.address)")
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.regular))
                        .foregroundStyle(DSColor.sand600)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isPicked {
                    DSIconView(.check, size: 16, color: DSColor.brandPrimary)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(isPicked ? DSColor.green50 : DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                    .strokeBorder(isPicked ? DSColor.brandPrimary : DSColor.border, lineWidth: 1)
            }
        }
        .buttonStyle(DSPressStyle())
        .accessibilityAddTraits(isPicked ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: - CTA

    @ViewBuilder
    private var cta: some View {
        if let picked = plan.pickedPlace {
            DSButton(L10n.placeSearchPickDone(picked.name), variant: .primary, action: onDone)
        } else {
            // 아무것도 고르지 않았으면 눌러도 갈 곳이 없다 — 프로토타입도 이 상태를 secondary로 잠근다.
            DSButton(L10n.tripFilterPickPrompt, variant: .secondary) {}
                .disabled(true)
                .opacity(0.5)
        }
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
