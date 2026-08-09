//
//  DSSegmentedControl.swift
//  UIComponents
//
//  원본: components/navigation/SegmentedControl.jsx
//

import SwiftUI

public struct DSSegmentedOption: Identifiable, Sendable {
    public let id: String
    public let label: String

    public init(id: String, label: String) {
        self.id = id
        self.label = label
    }
}

public struct DSSegmentedControl: View {
    private let options: [DSSegmentedOption]
    @Binding private var selection: String
    private let activeTint: Color
    private let isCompact: Bool

    public init(
        options: [DSSegmentedOption],
        selection: Binding<String>,
        activeTint: Color = DSColor.brandPrimaryDark,
        isCompact: Bool = false
    ) {
        self.options = options
        self._selection = selection
        self.activeTint = activeTint
        self.isCompact = isCompact
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(options) { option in
                let isActive = option.id == selection
                Button {
                    withAnimation(DSMotion.standard(duration: DSMotion.fast)) {
                        selection = option.id
                    }
                } label: {
                    Text(option.label)
                        .font(DSTypography.font(fontSize, weight: DSTypography.Weight.bold))
                        .foregroundStyle(isActive ? activeTint : DSColor.sand400)
                        .padding(.vertical, isCompact ? 6 : DSSpacing.s2)
                        .padding(.horizontal, isCompact ? DSSpacing.s3 : 0)
                        .frame(maxWidth: isCompact ? nil : .infinity)
                        .background {
                            if isActive {
                                RoundedRectangle(cornerRadius: itemRadius, style: .continuous)
                                    .fill(DSColor.surface)
                                    .dsShadow(DSShadow.sm)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DSSpacing.s1)
        .background(DSColor.sand100)
        .clipShape(RoundedRectangle(cornerRadius: containerRadius, style: .continuous))
    }

    private var fontSize: CGFloat {
        isCompact ? DSTypography.Size.xs2 : DSTypography.Size.base
    }

    private var itemRadius: CGFloat {
        isCompact ? DSRadius.sm : DSRadius.md
    }

    private var containerRadius: CGFloat {
        isCompact ? DSRadius.md : DSRadius.lg
    }
}

#Preview {
    @Previewable @State var tab = "ranking"
    @Previewable @State var period = "week"

    return VStack(spacing: DSSpacing.s5) {
        DSSegmentedControl(
            options: [
                .init(id: "ranking", label: "랭킹"),
                .init(id: "growth", label: "성장"),
            ],
            selection: $tab
        )

        DSSegmentedControl(
            options: [
                .init(id: "week", label: "주간"),
                .init(id: "month", label: "월간"),
                .init(id: "all", label: "전체"),
            ],
            selection: $period,
            isCompact: true
        )
    }
    .padding(DSSpacing.s5)
    .background(DSColor.bgApp)
}
