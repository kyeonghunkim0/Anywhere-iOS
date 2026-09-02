//
//  DSRegionBadge.swift
//  UIComponents
//
//  지역 뱃지 한 장으로 모든 상태를 그리는 메달리온.
//  이미지는 "그 지역이 어떻게 생겼나"(정체성)만 담고, 레벨·잠금 같은 상태는
//  전부 여기서 코드로 얹는다 — 레벨마다 뱃지를 새로 만들지 않기 위해서다.
//
//  · 센터: 서버 뱃지 PNG. 없으면 지역명 타이포 토큰으로 대신한다.
//  · 링: 레벨 5칸 게이지. 최고 레벨에서만 골드 그라데이션으로 바뀐다.
//  · 잠금: 채도를 빼고 흐린다.
//

import SwiftUI

public struct DSRegionBadge: View {
    /// 레벨 게이지 칸 수. 서버의 레벨 정의(Lv.1~5)와 같다.
    public static let maxLevel = 5

    private let imageURL: URL?
    private let name: String
    private let seed: String
    private let level: Int?
    private let isLocked: Bool
    private let diameter: CGFloat

    /// - Parameters:
    ///   - name: 타이포 토큰에 쓸 지역 이름. "강원 고성군"처럼 시·도가 붙어 있어도 된다.
    ///   - seed: 토큰 색을 고르는 고정 시드. 같은 지역이 어느 화면에서나 같은 색이도록 regionId를 넘긴다.
    ///   - level: 지역의 성장 레벨. nil이면 링을 그리지 않는다.
    public init(
        imageURL: URL? = nil,
        name: String,
        seed: String,
        level: Int? = nil,
        isLocked: Bool = false,
        diameter: CGFloat = 64
    ) {
        self.imageURL = imageURL
        self.name = name
        self.seed = seed
        self.level = level
        self.isLocked = isLocked
        self.diameter = diameter
    }

    public var body: some View {
        ZStack {
            center
                .frame(width: innerDiameter, height: innerDiameter)
                // 뱃지 PNG는 자체 흰 사각 배경을 갖고 온다 — 원으로 잘라야
                // 링 안에 들어앉은 메달로 읽히고, 모서리가 링을 뚫지 않는다.
                .clipShape(Circle())
                .saturation(isLocked ? 0 : 1)
                .opacity(isLocked ? 0.45 : 1)

            if level != nil {
                ring
            }
        }
        .frame(width: diameter, height: diameter)
    }

    // MARK: - 센터

    @ViewBuilder
    private var center: some View {
        if let imageURL {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                // 로딩 중에 타이포 토큰을 띄우면 그림이 도착할 때 색이 튄다.
                // 자리만 조용히 잡아 둔다.
                Circle().fill(DSColor.surfaceSunken)
            }
        } else {
            token
        }
    }

    /// 아직 뱃지 그림이 없는 지역의 자리. 새싹 하나로 다 같아 보이는 대신
    /// 지역명을 새긴 색 원으로 그려서 지역마다 다르게 읽히게 한다.
    private var token: some View {
        Circle()
            .fill(tokenColor)
            .overlay {
                Text(Self.shortName(name))
                    .font(DSTypography.font(innerDiameter * 0.34, weight: DSTypography.Weight.extrabold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, innerDiameter * 0.14)
            }
    }

    // MARK: - 레벨 링

    private var ring: some View {
        let filled = min(max(level ?? 0, 0), Self.maxLevel)

        return ZStack {
            ForEach(0 ..< Self.maxLevel, id: \.self) { index in
                Circle()
                    .trim(from: fraction(index) + Self.segmentGap, to: fraction(index + 1) - Self.segmentGap)
                    .stroke(
                        segmentStyle(isFilled: index < filled),
                        style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                    )
            }
        }
        .padding(ringWidth / 2)
        .rotationEffect(.degrees(-90))
        .saturation(isLocked ? 0 : 1)
        .opacity(isLocked ? 0.5 : 1)
    }

    private func segmentStyle(isFilled: Bool) -> AnyShapeStyle {
        guard isFilled else { return AnyShapeStyle(DSColor.tierTrack) }
        // 최고 레벨만 골드로 바뀐다 — 등급색을 다섯 개 만들면 근거 없는 사다리가 된다.
        guard (level ?? 0) >= Self.maxLevel else { return AnyShapeStyle(DSColor.tierFill) }
        return AnyShapeStyle(
            AngularGradient(
                colors: [DSColor.tierMax, DSColor.tierMaxDeep, DSColor.tierMax],
                center: .center
            )
        )
    }

    private func fraction(_ index: Int) -> CGFloat {
        CGFloat(index) / CGFloat(Self.maxLevel)
    }

    // MARK: - 치수

    private static let segmentGap: CGFloat = 0.022

    private var ringWidth: CGFloat { max(diameter * 0.055, 2) }

    /// 링을 그리는 만큼 센터를 안으로 들인다. 링이 없으면 자리를 다 쓴다.
    private var innerDiameter: CGFloat {
        level == nil ? diameter : diameter - (ringWidth * 2 + diameter * 0.06)
    }

    // MARK: - 토큰 색

    /// 지역마다 항상 같은 색이 나오도록 시드로 고정 해시를 만들어 팔레트에서 고른다.
    /// 임의 색을 만들지 않고 디자인 시스템 안에서만 고르는 게 요점이다.
    private var tokenColor: Color {
        let palette: [Color] = [
            DSColor.green600,
            DSColor.stamp600,
            DSColor.airmail500,
            DSColor.green800,
            DSColor.stamp700,
            DSColor.sand600,
            DSColor.red400,
            DSColor.green400,
        ]
        let hash = seed.unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) % 100_003 }
        return palette[abs(hash) % palette.count]
    }

    /// "강원 고성군" → "고성". 뒤에 붙는 시/군/구는 떼되, 떼고 나면 한 글자만
    /// 남는 이름("중구")은 그대로 둔다.
    static func shortName(_ name: String) -> String {
        let last = name.split(separator: " ").last.map(String.init) ?? name
        guard let suffix = last.last, "시군구".contains(suffix) else { return last }
        let trimmed = String(last.dropLast())
        return trimmed.count >= 2 ? trimmed : last
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            DSRegionBadge(name: "강원 고성군", seed: "a", level: 1)
            DSRegionBadge(name: "경상북도 안동시", seed: "b", level: 3)
            DSRegionBadge(name: "인천 중구", seed: "c", level: 5)
        }
        HStack(spacing: 16) {
            DSRegionBadge(name: "전남 구례군", seed: "d", level: 2, isLocked: true)
            DSRegionBadge(name: "충남 부여군", seed: "e", level: 4, isLocked: true)
            DSRegionBadge(name: "제주 서귀포시", seed: "f")
        }
    }
    .padding(DSSpacing.s6)
    .background(Color.white)
}
