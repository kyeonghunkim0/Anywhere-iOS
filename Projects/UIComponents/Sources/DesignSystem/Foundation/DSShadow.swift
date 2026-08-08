//
//  DSShadow.swift
//  UIComponents
//
//  아무데나 디자인 시스템의 그림자 토큰입니다. (원본: tokens/effects.css)
//  잉크빛이 도는 따뜻한 브라운-블랙 그림자를 사용합니다.
//

import SwiftUI

public struct DSShadowStyle: Sendable {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public static let none = DSShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
}

public enum DSShadow {
    public static let sm = DSShadowStyle(color: DSColor.ink900.opacity(0.06), radius: 2, x: 0, y: 1)
    public static let md = DSShadowStyle(color: DSColor.ink900.opacity(0.10), radius: 8, x: 0, y: 4)
    public static let lg = DSShadowStyle(color: DSColor.ink900.opacity(0.14), radius: 16, x: 0, y: 10)
    public static let xl = DSShadowStyle(color: DSColor.ink900.opacity(0.18), radius: 26, x: 0, y: 20)
    public static let xl2 = DSShadowStyle(color: DSColor.ink900.opacity(0.28), radius: 32, x: 0, y: 25)
    /// 히어로 버튼 아래에 쓰이는 스탬프-잉크 톤의 시그니처 컬러 그림자입니다.
    public static let brand = DSShadowStyle(color: DSColor.stamp500.opacity(0.4), radius: 22, x: 0, y: 16)
    public static let nav = DSShadowStyle(color: DSColor.ink900.opacity(0.08), radius: 13, x: 0, y: -10)
}

public extension View {
    func dsShadow(_ style: DSShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
