//
//  DSIconView.swift
//  UIComponents
//
//  DSIcon을 24×24 그리드 기준으로 스케일링해 그리는 뷰입니다. (원본: components/iconography/Icon.jsx)
//

import SwiftUI

public struct DSIconView: View {
    private let icon: DSIcon
    private let size: CGFloat
    private let color: Color
    private let strokeWidth: CGFloat

    public init(_ icon: DSIcon, size: CGFloat = 20, color: Color = DSColor.textPrimary, strokeWidth: CGFloat = 1.8) {
        self.icon = icon
        self.size = size
        self.color = color
        self.strokeWidth = strokeWidth
    }

    public var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 24
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            for element in icon.elements {
                let path = element.path.applying(transform)
                if icon.isFilled || element.alwaysFilled {
                    context.fill(path, with: .color(color))
                } else {
                    context.stroke(
                        path,
                        with: .color(color),
                        style: StrokeStyle(lineWidth: strokeWidth * scale, lineCap: .round, lineJoin: .round)
                    )
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
