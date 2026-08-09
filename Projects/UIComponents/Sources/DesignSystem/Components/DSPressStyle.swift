//
//  DSPressStyle.swift
//  UIComponents
//
//  버튼을 누르는 동안 95%로 축소되는 공통 인터랙션입니다.
//  디자인 시스템 전반에서 "Buttons scale to 95% on press" 규칙으로 통일되어 있습니다.
//

import SwiftUI

public struct DSPressStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(DSMotion.standard(duration: DSMotion.fast), value: configuration.isPressed)
    }
}
