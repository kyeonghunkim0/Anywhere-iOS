//
//  DSColor.swift
//  UIComponents
//
//  아무데나 디자인 시스템의 색상 토큰입니다. (원본: tokens/colors.css)
//  실제 색상 값은 Resources/Assets.xcassets의 Color Set이 갖고 있으며,
//  Tuist가 커스텀 신디사이저(Tuist/ResourceSynthesizers/Colors.stencil)로 생성한
//  `Colors.<name>.color`를 의미 단위 이름으로 다시 노출합니다.
//

import SwiftUI

public enum DSColor {
    // MARK: - Primitives

    public static let green50 = Colors.green50.color
    public static let green100 = Colors.green100.color
    public static let green200 = Colors.green200.color
    public static let green300 = Colors.green300.color
    public static let green400 = Colors.green400.color
    public static let green500 = Colors.green500.color
    public static let green600 = Colors.green600.color
    public static let green700 = Colors.green700.color
    public static let green800 = Colors.green800.color

    public static let stamp400 = Colors.stamp400.color
    public static let stamp500 = Colors.stamp500.color
    public static let stamp600 = Colors.stamp600.color
    public static let stamp700 = Colors.stamp700.color

    public static let airmail500 = Colors.airmail500.color
    public static let airmail100 = Colors.airmail100.color

    public static let yellowKakao = Colors.yellowKakao.color

    public static let red400 = Colors.red400.color
    public static let red500 = Colors.red500.color

    public static let paper50 = Colors.paper50.color
    public static let paper100 = Colors.paper100.color

    public static let sand50 = Colors.sand50.color
    public static let sand100 = Colors.sand100.color
    public static let sand200 = Colors.sand200.color
    public static let sand300 = Colors.sand300.color
    public static let sand400 = Colors.sand400.color
    public static let sand500 = Colors.sand500.color
    public static let sand600 = Colors.sand600.color
    public static let sand700 = Colors.sand700.color
    public static let sand800 = Colors.sand800.color

    public static let ink900 = Colors.ink900.color

    // MARK: - Semantic — Surfaces

    public static let bgApp = paper50
    public static let surface = Colors.surface.color
    public static let surfaceSunken = sand50
    public static let surfaceDark = ink900
    public static let border = sand200
    public static let borderStrong = sand300

    // MARK: - Semantic — Brand

    public static let brandPrimary = green500
    public static let brandPrimaryLight = green400
    public static let brandPrimaryDark = green600
    public static let brandAccent = stamp500
    public static let kakao = yellowKakao

    // MARK: - Semantic — Status

    public static let success = green500
    public static let successDeep = green700
    public static let successBg = green100
    public static let info = airmail500
    public static let infoBg = airmail100
    public static let danger = red500

    // MARK: - Semantic — Text

    public static let textPrimary = sand800
    public static let textSecondary = sand500
    public static let textMuted = sand400
    public static let textOnBrand = Color.white
    public static let textOnKakao = Colors.textOnKakao.color

    // MARK: - Semantic — Link

    public static let link = green600
    public static let linkHover = green700

    // MARK: - Overlay

    public static let overlayScrim = ink900.opacity(0.55)
}
