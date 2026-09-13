//
//  PlaceSearchView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isSpotSearch 화면.
//  "내 맘대로"로 들어오는 목적지 직접 선택. 고른 결과는 조건 화면이 이어받으므로
//  선택 상태는 이 화면이 아니라 TripPlanModel에 쓴다.
//  검색어를 치면 GET /api/search가 결과를 내려주고, 비우면 추천 목록으로 돌아간다.
//

import SwiftUI
import Domain
import UIComponents

struct PlaceSearchView: View {
    @State private var viewModel: PlaceSearchViewModel
    private let onBack: () -> Void
    private let onDone: () -> Void
    private let onOpenRegion: (String) -> Void

    @Environment(TripPlanModel.self) private var plan
    @FocusState private var isFieldFocused: Bool

    init(
        viewModel: PlaceSearchViewModel,
        onBack: @escaping () -> Void = {},
        onDone: @escaping () -> Void = {},
        onOpenRegion: @escaping (String) -> Void = { _ in }
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onBack = onBack
        self.onDone = onDone
        self.onOpenRegion = onOpenRegion
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            content
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            cta
                .padding(.horizontal, DSSpacing.s6)
                .padding(.top, 14)
                .padding(.bottom, 30)
                .background(Color.white)
        }
        .task { await viewModel.load() }
        // 검색어를 지우거나 바꿔서 고른 장소가 목록에서 빠지면 선택도 함께 접는다 —
        // 화면에 없는 장소를 "선택완료" 버튼만 계속 들고 있으면 혼란스럽다.
        .onChange(of: viewModel.results) { _, results in
            if let picked = plan.pickedPlace, !results.contains(where: { $0.id == picked.id }) {
                plan.pickedPlace = nil
            }
        }
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

    // MARK: - 상단

    /// 프로토타입은 뒤로가기 옆에 "MY OWN PICK" 라벨을 두고, 그 아래로 큰 제목과
    /// 검색창을 세로로 쌓는다 — 뒤로가기와 검색창을 한 줄에 붙이던 이전 배치를 갈음한다.
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Button(action: onBack) {
                    DSIconView(.chevronRight, size: 18, color: DSColor.ink900)
                        .rotationEffect(.degrees(180))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(DSPressStyle())
                .accessibilityLabel(L10n.commonBack)

                Text(L10n.placeSearchEyebrow)
                    .font(DSTypography.font(10, weight: DSTypography.Weight.extrabold))
                    .tracking(10 * 0.14)
                    .foregroundStyle(DSColor.brandPrimary)
            }
            // 아이콘 버튼의 탭 영역만큼 왼쪽으로 물려 글자 기준선을 본문에 맞춘다.
            .padding(.leading, -10)

            Text(L10n.placeSearchTitle)
                .font(DSTypography.font(30, weight: DSTypography.Weight.extrabold))
                .tracking(30 * -0.035)
                .lineSpacing(DSTypography.lineSpacing(size: 30, leading: 1.18))
                .foregroundStyle(DSColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)

            searchField
                .padding(.top, 20)

            // 검색 중에는 감춘다 — 서버가 페이지로 끊어 주는 결과에 권역을 덧씌우면
            // 걸러진 몇 건이 전체인 것처럼 보인다.
            if !viewModel.hasKeyword {
                regionChips
                    .padding(.top, 12)
            }
        }
        .padding(.horizontal, DSSpacing.s6)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    /// 검색어가 있으면 테두리·아이콘이 브랜드색으로 살고 바깥에 옅은 링이 돈다.
    private var searchField: some View {
        HStack(spacing: 10) {
            DSIconView(.target, size: 17, color: viewModel.hasKeyword ? DSColor.brandPrimary : DSColor.sand500)

            TextField("", text: $viewModel.keyword)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.bold))
                .foregroundStyle(DSColor.textPrimary)
                .focused($isFieldFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                // 기본 placeholder 색이 옅어 거의 안 보여 직접 겹쳐 둔다.
                .overlay(alignment: .leading) {
                    if !viewModel.hasKeyword {
                        Text(L10n.placeSearchFieldPlaceholder)
                            .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.bold))
                            .foregroundStyle(DSColor.textSecondary)
                            .allowsHitTesting(false)
                    }
                }

            if viewModel.hasKeyword {
                Button {
                    viewModel.keyword = ""
                } label: {
                    DSIconView(.close, size: 11, color: DSColor.green700)
                        .frame(width: 22, height: 22)
                        .background(DSColor.green100)
                        .clipShape(Circle())
                }
                .buttonStyle(DSPressStyle())
                .accessibilityLabel(L10n.commonClose)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.white)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(
                    viewModel.hasKeyword ? DSColor.brandPrimary : DSColor.border,
                    lineWidth: 1.5
                )
        }
        .background {
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .fill(viewModel.hasKeyword ? DSColor.green50 : Color.clear)
                .padding(-4)
        }
    }

    private var regionChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 7) {
                ForEach(TripRegionFilter.allCases) { filter in
                    let isOn = viewModel.regionFilter == filter

                    Button {
                        viewModel.regionFilter = filter
                    } label: {
                        Text(filter.label)
                            .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.bold))
                            .foregroundStyle(isOn ? Color.white : DSColor.sand700)
                            .padding(.horizontal, 15)
                            .frame(height: 34)
                            .background(isOn ? DSColor.brandPrimary : Color.white)
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .strokeBorder(isOn ? DSColor.brandPrimary : DSColor.border, lineWidth: 1)
                            }
                    }
                    .buttonStyle(DSPressStyle())
                    .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
                }
            }
        }
        .scrollIndicators(.hidden)
        // 칩이 화면 가장자리까지 흐르도록 좌우 여백을 잠깐 무른다.
        .padding(.horizontal, -DSSpacing.s6)
        .contentMargins(.horizontal, DSSpacing.s6, for: .scrollContent)
    }

    // MARK: - List

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            centered { ProgressView() }
        } else if viewModel.isEmptyResult {
            empty
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 9) {
                    if !viewModel.festivals.isEmpty {
                        festivalSection
                            .padding(.bottom, 8)
                    }

                    Text(viewModel.listHeading)
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.bold))
                        .foregroundStyle(DSColor.sand600)
                        .padding(.bottom, 4)

                    ForEach(viewModel.results) { place in
                        row(place)
                    }

                    // 목록 끝이 보이면 다음 쪽을 붙인다. 서버가 이름 일치도 순으로
                    // 정렬해 주므로 위쪽부터 좋은 결과다 — 굳이 다 받아 두지 않는다.
                    // id를 현재 개수로 고정해 둔다 — 로딩 중이라고 이 뷰 자체를 감추면
                    // 진행 중인 .task가 취소되고, 그 취소가 네트워크 에러로 잡혀 알럿이
                    // 뜨면서 같은 페이지를 무한히 다시 쏜다.
                    if viewModel.hasMorePages {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .task(id: viewModel.results.count) { await viewModel.loadMore() }
                    }
                }
                .padding(.horizontal, DSSpacing.s6)
                .padding(.bottom, DSSpacing.s8)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    private var empty: some View {
        VStack(spacing: 0) {
            DSIconView(.compass, size: 24, color: DSColor.green300)
                .frame(width: 56, height: 56)
                .background(DSColor.green50)
                .clipShape(Circle())

            Text(L10n.placeSearchEmptyTitle)
                .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                .foregroundStyle(DSColor.textPrimary)
                .padding(.top, 16)

            Text(L10n.placeSearchEmptyBody)
                .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                .foregroundStyle(DSColor.sand600)
                .padding(.top, 6)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 34)
        .padding(.horizontal, DSSpacing.s6)
    }

    private func row(_ place: TaggedPlace) -> some View {
        let isPicked = plan.pickedPlace?.id == place.id

        return Button {
            isFieldFocused = false
            // 다시 누르면 해제된다 — 프로토타입과 같은 토글이다.
            plan.pickedPlace = isPicked ? nil : place
        } label: {
            HStack(spacing: 13) {
                DSIconView(
                    .pin,
                    size: 19,
                    color: isPicked ? DSColor.brandPrimary : DSColor.sand600
                )
                .frame(width: 40, height: 40)
                .background(isPicked ? DSColor.green100 : DSColor.sand100)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(place.name)
                        .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                        .tracking(DSTypography.Size.base * -0.02)
                        .foregroundStyle(isPicked ? DSColor.green700 : DSColor.textPrimary)
                        .lineLimit(1)

                    Text("\(place.displayName) · \(place.address)")
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.sand600)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 위치 권한이 없거나 장소에 좌표가 없으면 자리째 비운다.
                if let distanceKm = viewModel.distanceKm(to: place) {
                    Text(Self.distanceLabel(distanceKm))
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(isPicked ? DSColor.brandPrimary : DSColor.sand700)
                }

                if isPicked {
                    DSIconView(.check, size: 13, color: Color.white)
                        .frame(width: 24, height: 24)
                        .background(DSColor.brandPrimary)
                        .clipShape(Circle())
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(isPicked ? DSColor.green50 : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isPicked ? DSColor.brandPrimary : DSColor.border, lineWidth: 1.5)
            }
            .dsShadow(isPicked ? DSShadow.pick : .none)
        }
        .buttonStyle(DSPressStyle())
        .accessibilityAddTraits(isPicked ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: - 축제

    private var festivalSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(L10n.placeSearchHeadingFestivals)
                .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.bold))
                .foregroundStyle(DSColor.sand600)

            ForEach(viewModel.festivals) { festival in
                festivalRow(festival)
            }
        }
    }

    private func festivalRow(_ festival: Festival) -> some View {
        Button {
            onOpenRegion(festival.region.id)
        } label: {
            HStack(spacing: 13) {
                RegionBadgeIcon(
                    badge: RegionBadge(
                        key: festival.key,
                        name: festival.name,
                        description: festival.description,
                        iconURL: festival.iconURL
                    ),
                    name: festival.name,
                    seed: festival.key,
                    diameter: 40
                )

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(festival.name)
                            .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.extrabold))
                            .tracking(DSTypography.Size.base * -0.02)
                            .foregroundStyle(DSColor.textPrimary)
                            .lineLimit(1)

                        festivalStatusBadge(festival.status)
                    }

                    Text("\(festival.displayName) · \(festival.description)")
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.sand600)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 종료된 축제는 남은 일수가 의미 없어 자리를 비운다.
                if festival.status != .expired {
                    Text(L10n.placeSearchFestivalDaysLeft(max(festival.daysRemaining, 0)))
                        .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.sand700)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DSColor.border, lineWidth: 1.5)
            }
        }
        .buttonStyle(DSPressStyle())
    }

    private func festivalStatusBadge(_ status: FestivalStatus) -> some View {
        let (label, foreground, background): (String, Color, Color) = switch status {
        case .upcoming: (L10n.placeSearchFestivalStatusUpcoming, DSColor.info, DSColor.infoBg)
        case .active: (L10n.placeSearchFestivalStatusActive, DSColor.successDeep, DSColor.successBg)
        case .expired: (L10n.placeSearchFestivalStatusExpired, DSColor.textMuted, DSColor.sand100)
        }

        return Text(label)
            .font(DSTypography.font(DSTypography.Size.xs2, weight: DSTypography.Weight.extrabold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(background)
            .clipShape(Capsule())
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

    /// 직선 거리라 1km 밑에서 숫자를 내밀면 정확한 척이 된다 — 그때는 문구로 뭉갠다.
    private static func distanceLabel(_ km: Double) -> String {
        km < 1 ? L10n.placeSearchDistanceNear : L10n.placeSearchDistanceKm(Int(km.rounded()))
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
