//
//  DSTypography.swift
//  UIComponents
//
//  아무데나 디자인 시스템의 타이포그래피 토큰입니다. (원본: tokens/typography.css)
//  Pretendard 대신 시스템 폰트(San Francisco / Apple SD Gothic Neo)로 매핑합니다.
//

import SwiftUI

public enum DSTypography {
    public enum Size {
        public static let xs2: CGFloat = 11
        public static let xs: CGFloat = 12
        public static let sm: CGFloat = 13
        public static let base: CGFloat = 15
        public static let md: CGFloat = 17
        public static let lg: CGFloat = 20
        public static let xl: CGFloat = 24
        public static let xl2: CGFloat = 30
        public static let xl3: CGFloat = 38
        public static let xl4: CGFloat = 48
    }

    public enum Weight {
        public static let light = Font.Weight.light
        public static let regular = Font.Weight.regular
        public static let semibold = Font.Weight.semibold
        public static let bold = Font.Weight.bold
        public static let extrabold = Font.Weight.heavy
    }

    public enum Leading {
        public static let tight: CGFloat = 1.2
        public static let normal: CGFloat = 1.45
        public static let relaxed: CGFloat = 1.6
    }

    public static let trackingWide: CGFloat = 0.04

    public static func font(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    public static func lineSpacing(size: CGFloat, leading: CGFloat = Leading.normal) -> CGFloat {
        size * (leading - 1)
    }

    public static func tracking(size: CGFloat) -> CGFloat {
        size * trackingWide
    }
}
