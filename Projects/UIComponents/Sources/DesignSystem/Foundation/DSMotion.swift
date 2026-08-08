//
//  DSMotion.swift
//  UIComponents
//
//  아무데나 디자인 시스템의 모션 토큰입니다. (원본: tokens/motion.css)
//

import SwiftUI

public enum DSMotion {
    public static let fast: Double = 0.15
    public static let base: Double = 0.30
    public static let slow: Double = 0.80

    public static func standard(duration: Double = base) -> Animation {
        .timingCurve(0.4, 0, 0.2, 1, duration: duration)
    }

    public static func bounce(duration: Double = base) -> Animation {
        .timingCurve(0.34, 1.56, 0.64, 1, duration: duration)
    }
}
