//
//  DSProgressBar.swift
//  UIComponents
//
//  원본: components/feedback/ProgressBar.jsx
//

import SwiftUI

public enum DSProgressTone: Sendable {
    case brand
    case success

    var color: Color {
        switch self {
        case .brand: return DSColor.brandPrimary
        case .success: return DSColor.success
        }
    }
}

public struct DSProgressBar: View {
    private let value: Double
    private let tone: DSProgressTone
    private let isStriped: Bool
    private let height: CGFloat

    /// - Parameter value: 0...100 범위의 진행률입니다. 범위를 벗어난 값은 잘라냅니다.
    public init(
        value: Double,
        tone: DSProgressTone = .brand,
        isStriped: Bool = false,
        height: CGFloat = 8
    ) {
        self.value = value
        self.tone = tone
        self.isStriped = isStriped
        self.height = height
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(DSColor.green100)

                Capsule()
                    .fill(tone.color)
                    .overlay {
                        if isStriped {
                            stripes.clipShape(Capsule())
                        }
                    }
                    .frame(width: proxy.size.width * clampedRatio)
            }
        }
        .frame(height: height)
        .animation(DSMotion.standard(duration: DSMotion.slow), value: clampedRatio)
    }

    private var clampedRatio: CGFloat {
        CGFloat(min(100, max(0, value)) / 100)
    }

    /// CSS의 `repeating-linear-gradient(45deg, …)`를 그대로 옮긴 사선 줄무늬입니다.
    /// 줄무늬 두께 10pt, 주기 20pt(수직 기준)이므로 x축 간격은 20 * √2가 됩니다.
    private var stripes: some View {
        Canvas { context, size in
            let period = 20 * (2.0 as CGFloat).squareRoot()
            var x = -size.height
            while x < size.width + size.height {
                var path = Path()
                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height, y: 0))
                context.stroke(path, with: .color(.white.opacity(0.16)), lineWidth: 10)
                x += period
            }
        }
    }
}

#Preview {
    VStack(spacing: DSSpacing.s5) {
        DSProgressBar(value: 35)
        DSProgressBar(value: 72, tone: .success)
        DSProgressBar(value: 58, isStriped: true, height: 14)
    }
    .padding(DSSpacing.s5)
    .background(DSColor.bgApp)
}
